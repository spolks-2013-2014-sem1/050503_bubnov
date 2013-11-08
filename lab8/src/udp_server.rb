require 'process_shared'
require 'securerandom'
require_relative '../../spolks_lib/network'

def udp_server(opts)
  processes = []

  mutex = ProcessShared::Mutex.new
  mem = ProcessShared::SharedMemory.new(65535)
  mem.write_object({})

  server = Network::DatagramSocket.new
  server.bind(Socket.sockaddr_in(opts[:port], ''))

  (0..7).each do
    processes << fork do
      begin
        loop do
          rs, _ = IO.select([server], nil, nil)

          rs.each do |s|
            data, who = s.recvfrom(Network::CHUNK_SIZE)
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

                if data == Network::FIN
                  connections.delete(who)
                  next
                end

                file = file || File.open(connections[who], 'a+')
                file.write(data)
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
    Process.kill('TERM', proc)
  end
end
