require_relative '../../spolks_lib/network'

def udp_server(opts)
  threads = []
  clients = {}
  mutex = Mutex.new
  num = opts[:num] ? opts[:num] : 7

  packet = Network::Packet.new
  server = Network::DatagramSocket.new
  server.bind(Socket.sockaddr_in(opts[:port], ''))

  (1..num).each do
    threads << Thread.new do
      loop do
        rs, _ = IO.select([server], nil, nil, Network::TIMEOUT)
        break unless rs

        rs.each do |s|
          data, who = s.recvfrom_nonblock(Network::CHUNK_SIZE + 12) rescue nil
          next unless who

          s.send(Network::ACK, 0, who)
          who = who.ip_unpack.to_s
          next if data == Network::FIN

          mutex.synchronize do
            packet.read(data)
            unless clients[who]
              clients[who] = { file: File.open("#{SecureRandom.hex}.ld", 'w+'),
                               chunks: packet.chunks }
            end

            clients[who][:file].seek(packet.seek * Network::CHUNK_SIZE)
            clients[who][:file].write(packet.data)
            clients[who][:chunks] -= 1

            if clients[who][:chunks] == 0
              clients[who][:file].close
              clients.delete(who)
              next
            end
          end
        end
      end
    end
  end

  threads.each(&:run)
  threads.each(&:join)
ensure
  server.close if server
  threads.each(&:exit)
  p clients
  clients.each do |key, hash|
    hash[:file].close if file
  end
end
