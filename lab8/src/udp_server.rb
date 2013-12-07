require 'process_shared'
require 'securerandom'
require_relative '../../spolks_lib/stream_socket'


def udp_server(opts)
  processes = []
  num = opts[:num] ? opts[:num] : 7

  packet = Network::Packet.new
  mutex = ProcessShared::Mutex.new
  mem = ProcessShared::SharedMemory.new(65535)
  mem.write_object({})

  server = Network::DatagramSocket.new
  server.bind(Socket.sockaddr_in(opts[:port], ''))

  (1..num).each do
    processes << fork do
      begin
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
              begin
                file = nil
                connections = mem.read_object
                packet.read(data)

                unless connections[who]
                  file_name = "#{SecureRandom.hex}.ld"
                  connections[who] = { chunks: packet.chunks.to_s, file: file_name }
                  file = File.open(file_name, 'w+')
                end

                file = file || File.open(connections[who][:file], 'r+')
                file.seek(packet.seek * Network::CHUNK_SIZE)
                file.write(packet.data)

                chunks = Integer(connections[who][:chunks]) - 1
                connections[who][:chunks] = chunks.to_s
                if chunks == 0
                  connections.delete(who)
                  next
                end
              ensure
                mem.write_object(connections)
                file.close if file
              end
            end
          end
        end
      ensure
        server.close if server
      end
    end
  end

  Process.waitall
ensure
  server.close if server
end
