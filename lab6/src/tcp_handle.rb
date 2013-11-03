require_relative '../../spolks_lib/network'

MSG = '!'

def tcp_server_handle(opts)
  server = Network::AbstractSocket.open(:tcp)
  server.bind(Socket.sockaddr_in(opts[:port], Network::INADDR_ANY))
  server.listen(3)

  count = 0
  threads = {}

  loop do
    begin
      socket, = server.accept_nonblock
    rescue
    end

    if socket
      threads[socket] = {
          file: File.open("o#{count += 1}", File::CREAT|File::TRUNC|File::WRONLY),
          recv: 0,
          read_oob: true
      }
    end

    urgent_arr = []
    threads.each do |socket, data|
      urgent_arr.push(socket) if data[:read_oob]
    end

    rs, _, us = IO.select(threads.keys, nil, urgent_arr, Network::TIMEOUT)
    rs, us = rs || [], us || []

    us.each do |s|
      s.recv(1, Network::StreamSocket::MSG_OOB)
      puts "#{s} #{threads[s][:recv]}" if opts.verbose?
      threads[s][:read_oob] = false
    end

    rs.each do |s|
      data = s.recv(Network::CHUNK_SIZE)

      if data.empty?
        s.close
        threads[s][:file].close
        threads.delete(s)

        next
      end

      threads[s][:recv] += data.length
      threads[s][:read_oob] = true

      threads[s][:file].write(data)
    end

  end
ensure
  server.close if server

  threads.each do |client, data|
    client.close if client
    data[:file].close()
  end
end


def tcp_client_handle(opts)
  file = File.open(opts[:file], File::RDONLY)
  client = Network::AbstractSocket.open(:tcp)
  client.connect(Socket.sockaddr_in(opts[:port], opts[:host]))

  sent_oob = 0
  sent = true
  transferred = 0

  loop do
    sent_oob += 1 if opts.verbose?
    _, ws, = IO.select(nil, [client], nil, Network::TIMEOUT)

    break unless ws
    data, sent = file.read(Network::CHUNK_SIZE), false if sent

    ws.each do |s|
      return unless data
      sent = true unless s.send(data, 0) == 0

      if opts.verbose? && sent_oob % 64 == 0
        sent_oob = 0
        s.send(MSG, Network::MSG_OOB)
      end

      transferred += data.length if sent
      puts(transferred) if opts.verbose?
    end
  end
ensure
  file.close if file
  client.close if client
end
