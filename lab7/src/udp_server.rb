require_relative '../../spolks_lib/network'

def udp_server(opts)
  count = 0
  threads = []
  clients = {}
  mutex = Mutex.new

  packet = Network::Packet.new
  server = Network::DatagramSocket.new
  server.bind(Socket.sockaddr_in(opts[:port], ''))

  (0..7).each do
    threads << Thread.new do
      loop do
        rs, _ = IO.select([server], nil, nil)

        rs.each do |s|
          data, who = s.recvfrom(Network::CHUNK_SIZE + 8)
          s.send(Network::ACK, 0, who)
          who = who.ip_unpack.to_s

          mutex.synchronize do
            unless clients[who]
              clients[who] = File.open("o#{count += 1}", 'w+')
            end

            if data == Network::FIN
              clients[who].close
              clients.delete(who)
              next
            end

            packet.read(data)
            clients[who].seek(packet.seek * Network::CHUNK_SIZE)
            clients[who].write(packet.data)
          end
        end
      end
    end
  end

  threads.each(&:join)
ensure
  server.close if server
  threads.each(&:exit)
  clients.each do |key, file|
    file.close if file
  end
end
