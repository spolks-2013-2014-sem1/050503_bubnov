require 'securerandom'
require_relative '../../spolks_lib/network'

def tcp_server(opts)
  connections = {}

  server = Network::StreamSocket.new
  server.bind(Socket.sockaddr_in(opts[:port], ''))
  server.listen(5)

  loop do
    urgent_arr = []
    connections.each do |socket, data|
      urgent_arr.push(socket) if data[:read_oob]
    end

    rs, _, us = IO.select(connections.keys + [server],
                          nil, urgent_arr, Network::TIMEOUT)

    break unless rs or us

    if rs.include?(server)
      rs.delete(server)
      socket, = server.accept
      connections[socket] = {
          file: File.open("#{SecureRandom.hex}.ld", 'w+'),
          recv: 0,
          read_oob: true,
      }
    end

    us.each do |s|
      s.recv(1, Network::MSG_OOB)
      puts "#{s} #{connections[s][:recv]}" if opts.verbose?
      connections[s][:read_oob] = false
    end

    rs.each do |s|
      attached = connections[s]
      data = s.recv(Network::CHUNK_SIZE)

      if data.empty?
        s.close
        attached[:file].close
        connections.delete(s)
        next
      end

      attached[:recv] += data.length
      attached[:read_oob] = true
      attached[:file].write(data)
    end
  end
ensure
  server.close if server
  connections.each do |socket, attached|
    socket.close if socket
    attached[:file].close if attached[:file]
  end
end
