require_relative '../../spolks_lib/network'

def udp_server_handle(opts)
  server = Network::AbstractSocket.open(:udp)
  server.bind(Socket.sockaddr_in(opts[:port], Network::INADDR_ANY))

  count = 0
  threads = {}

  loop do
    rs, _ = IO.select([server], nil, nil, Network::TIMEOUT)
    next unless rs

    rs.each do |s|
      recv = s.recv(Network::CHUNK_SIZE + 16)
      who = recv[0..15]
      data = recv[16..recv.length]

      if data.empty?
        threads[who].close if threads[who]
        threads.delete(who)
        next
      end

      unless threads[who]
        threads[who] = File.open("o#{count += 1}", File::CREAT|File::TRUNC|File::WRONLY)
      end

      threads[who].write(data)
    end
  end
ensure
  threads.each do |key, data|
    data.close
  end

  server.close if server
end


def udp_client_handle(opts)
  file = File.open(opts[:file], File::RDONLY)
  client = Network::AbstractSocket.open(:udp)
  client.connect(Socket.sockaddr_in(opts[:port], opts[:host]))
  sin = client.local_address.to_sockaddr

  sent = true

  loop do
    _, ws, = IO.select(nil, [client], nil, Network::TIMEOUT)

    break unless ws
    data, sent = file.read(Network::CHUNK_SIZE), false if sent
    data = sin + (data || '')

    ws.each do |s|
      sent = true unless s.send(data, 0) == 0
      return if data.length == sin.length
    end
  end
ensure
    file.close if file
    client.close if client
end
