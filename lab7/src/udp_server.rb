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

          mutex.synchronize do
            unless clients[who]
              clients[who] = File.open("#{SecureRandom.hex}.ld", 'w+')
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

  threads.each(&:run)
  threads.each(&:join)
ensure
  server.close if server
  threads.each(&:exit)
  clients.each do |key, file|
    file.close if file
  end
end
