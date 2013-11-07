require_relative '../../spolks_lib/network'

def udp_handle(opts)
  count = 0
  threads = []
  connections = {}

  server = Network::DatagramSocket.new
  server.bind(Socket.sockaddr_in(opts[:port], ''))

  (0..7).each do
    threads << Thread.new do
      loop do
        rs, _ = IO.select([server], nil, nil)
        break unless rs

        rs.each do |s|
          data, who = s.recvfrom(Network::CHUNK_SIZE)
          who = who.ip_unpack

          unless connections[who]
            connections[who] = File.open("o#{count += 1}", 'w+')
          end

          if data.empty?
            connections[who].close
            connections.delete(who)
            next
          end

          connections[who].write(data)
        end
      end
    end
  end

  threads.each(&:join)
ensure
  server.close if server
  threads.each(&:exit)
  connections.each do |key, file|
    file.close if file
  end
end
