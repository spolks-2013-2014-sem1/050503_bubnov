require_relative '../../spolks_lib/network'

def tcp_server(opts)
  count = 0
  threads = []

  server = Network::StreamSocket.new
  server.bind(Socket.sockaddr_in(opts[:port], ''))
  server.listen(3)

  loop do
    socket, = server.accept

    threads << Thread.new do
      begin
        file = File.open("o#{count += 1}", 'w+')
        tsock = socket
        recv = 0
        has_oob = true

        loop do
          urgent_arr = has_oob ? [tsock] : []
          rs, _, us = IO.select([tsock], nil, urgent_arr, Network::TIMEOUT)

          if s = us.shift
            s.recv(1, Network::MSG_OOB)
            puts "#{s} #{recv}" if opts.verbose?
            has_oob = false
          end

          if s = rs.shift
            data = s.recv(Network::CHUNK_SIZE)
            break if data.empty?

            recv += data.length
            has_oob = true

            file.write(data)
          end
        end

      ensure
        file.close if file
        tsock.close if tsock
      end
    end
  end
ensure
  threads.each(&:exit)
  server.close if server
end
