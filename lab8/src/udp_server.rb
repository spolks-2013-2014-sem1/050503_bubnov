require 'process_shared'
require 'securerandom'
require_relative '../../spolks_lib/network'

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
          rs, _ = IO.select([server], nil, nil)

          rs.each do |s|
            data, who = s.recvfrom(Network::CHUNK_SIZE + 8)
            s.send(Network::ACK, 0, who)
            who = who.ip_unpack.to_s

            mutex.synchronize do
              begin
                file = nil
                connections = mem.read_object

                unless connections[who]
                  file_name = "#{SecureRandom.hex}.ld"
                  connections[who] = file_name
                  file = File.open(file_name, 'w+')
                end

                next if data == Network::FIN
                packet.read(data)

                file = file || File.open(connections[who], 'r+')
                file.seek(packet.seek * Network::CHUNK_SIZE)
                file.write(packet.data)
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
  processes.each do |proc|
    Process.kill('KILL', proc)
  end
end
