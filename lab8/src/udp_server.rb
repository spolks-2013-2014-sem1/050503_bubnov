require 'process_shared'
require 'securerandom'

require_relative '../../spolks_lib/network'
require_relative '../../spolks_lib/file'

def udp_server(opts)
  processes = []
  num = opts[:num] ? opts[:num] : 7

  packet = Network::Packet.new
  mutex = ProcessShared::Mutex.new
  mem = ProcessShared::SharedMemory.new(65535)
  mem.write_object({})

  Network::DatagramSocket.listen opts do |socket|
    (1..num).each do
      processes << fork do
        loop do
          rs, = socket.select rs: true
          break unless rs

          data, who = socket.recv_nonblock rescue nil
          next unless who

          socket.send Network::ACK, who
          next if data == Network::FIN
          who = who.ip_unpack

          mutex.synchronize do
            begin
              file = nil
              connections = mem.read_object
              packet.read data

              unless connections[who]
                file_name = "#{SecureRandom.hex}.ld"
                connections[who] = { chunks: packet.chunks.to_s, file: file_name }
                file = XIO::XFile.new connections[who][:file]
              end

              file = file || XIO::XFile.new(connections[who][:file], 'r+')
              file.seek_chunk(packet.seek)
              file.write packet.data

              chunks = Integer(connections[who][:chunks]) - 1
              connections[who][:chunks] = chunks.to_s
              if chunks == 0
                connections.delete(who)
                next
              end
            ensure
              mem.write_object connections
              file.close if file
            end
          end
        end
      end
    end

    Process.waitall
  end
end
