require_relative '../../spolks_lib/network'

def tcp_server(opts)
  count = 0
  processes = []

  server = Network::StreamSocket.new
  server.bind(Socket.sockaddr_in(opts[:port], ''))
  server.listen(3)

  loop do
    socket, = server.accept
    count += 1

    processes << fork do
      begin
        server.close
        file = File.open("o#{count}", 'w+')
        recv = 0
        has_oob = true

        loop do
          urgent_arr = has_oob ? [socket] : []
          rs, _, us = IO.select([socket], nil, urgent_arr, Network::TIMEOUT)

          if s = us.shift
            s.recv(1, Network::MSG_OOB)
            puts "#{s} #{recv}" if opts.verbose?
            has_oob = false
          end

          if s = rs.shift
            data = s.recv(Network::CHUNK_SIZE)
            exit if data.empty?

            recv += data.length
            has_oob = true

            file.write(data)
          end
        end

      ensure
        file.close if file
        socket.close if socket
      end
    end
  end
ensure
  server.close if server
  processes.each do |pid|
    Process.kill('TERM', pid)
  end
end
