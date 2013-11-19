require_relative '../../spolks_lib/network'

def tcp_server(opts)
  count = 0
  threads = []

  mutex = Mutex.new
  server = Network::StreamSocket.new
  server.bind(Socket.sockaddr_in(opts[:port], ''))
  server.listen(3)

  loop do
    rs, _ = IO.select([server], nil, nil, Network::TIMEOUT)
    break unless rs

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
          break unless rs or us

          us.each do |s|
            s.recv(1, Network::MSG_OOB)
            puts "#{s} #{recv}" if opts.verbose?
            has_oob = false
          end

          rs.each do |s|
            data = s.recv(Network::CHUNK_SIZE)
            return if data.empty?

            recv += data.length
            has_oob = true

            file.write(data)
          end
        end

      ensure
        file.close if file
        tsock.close if tsock
        mutex.synchronize do
          threads.delete(Thread.current)
        end
      end
    end
  end

  mutex.synchronize do
    threads.each(&:join)
  end
ensure
  server.close if server
  mutex.synchronize do
    threads.each(&:exit)
  end
end
