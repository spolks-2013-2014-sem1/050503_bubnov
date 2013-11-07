require_relative '../../spolks_lib/network'

def tcp_handle(opts)
  count = 0
  threads = {}

  server = Network::StreamSocket.new
  server.bind(Socket.sockaddr_in(opts[:port], ''))
  server.listen(5)

  loop do
    begin
      socket, = server.accept_nonblock
    rescue
    end

    threads[socket] = {
        file: File.open("o#{count += 1}", 'w+'),
        recv: 0,
        read_oob: true,
    } if socket

    urgent_arr = []
    threads.each do |socket, data|
      urgent_arr.push(socket) if data[:read_oob]
    end

    rs, _, us = IO.select(threads.keys, nil, urgent_arr, 0)
    rs, us = rs || [], us || []

    us.each do |s|
      s.recv(1, Network::MSG_OOB)
      puts "#{s} #{threads[s][:recv]}" if opts.verbose?
      threads[s][:read_oob] = false
    end

    rs.each do |s|
      attached = threads[s]
      data = s.recv(Network::CHUNK_SIZE)

      if data.empty?
        s.close
        attached[:file].close
        threads.delete(s)
        next
      end

      attached[:recv] += data.length
      attached[:read_oob] = true
      attached[:file].write(data)
    end
  end
ensure
  server.close if server

  threads.each do |socket, attached|
    socket.close if socket
    attached[:file].close if attached[:file]
  end
end
