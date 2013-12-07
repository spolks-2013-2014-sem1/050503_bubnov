require_relative '../../spolks_lib/network'
require_relative '../../spolks_lib/file'

def udp_server(opts)
  threads = []
  clients = {}
  mutex = Mutex.new
  packet = Network::Packet.new
  num = opts[:num] ? opts[:num] : 7

  Network::DatagramSocket.listen opts do |socket|
    (1..num).each do
      threads << Thread.new do
        loop do
          rs, = socket.select rs: true
          break unless rs

          data, who = socket.recv_nonblock rescue nil
          next unless who

          socket.send Network::ACK, who
          next if data == Network::FIN
          who = who.ip_unpack

          mutex.synchronize do
            packet.read data
            unless clients[who]
              clients[who] = { file: XIO::XFile.new("#{SecureRandom.hex}.ld"),
                               chunks: packet.chunks }
            end

            file = clients[who][:file]
            file.seek_chunk packet.seek
            file.write packet.data
            clients[who][:chunks] -= 1

            if clients[who][:chunks] == 0
              file.close
              clients.delete(who)
              next
            end
          end
        end
      end
    end

    threads.each(&:join)
  end
ensure
  clients.each do |key, hash|
    hash[:file].close if file
  end
end
