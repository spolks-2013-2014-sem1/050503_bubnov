require 'securerandom'
require_relative '../../spolks_lib/network'

def tcp_server(opts)
  threads = {}

  server = Network::StreamSocket.new
  server.bind(Socket.sockaddr_in(opts[:port], ''))
  server.listen(5)

  loop do
    urgent_arr = []
    threads.each do |socket, data|
      urgent_arr.push(socket) if data[:read_oob]
    end

    rs, _, us = IO.select(threads.keys + [server],
                          nil, urgent_arr, Network::TIMEOUT)

    break unless rs or us

    if rs.include?(server)
      rs.delete(server)
      socket, = server.accept
      threads[socket] = {
          file: File.open("#{SecureRandom.hex}.ld", 'w+'),
          recv: 0,
          read_oob: true,
      }
    end

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
