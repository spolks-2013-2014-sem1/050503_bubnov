require_relative '../../spolks_lib/network'
require_relative '../../spolks_lib/file'

def udp_client(opts)
  sent = true
  seek = -1

  Network::DatagramSocket.open opts do |socket|
    XIO::XFile.read opts do |file, chunk|
      seek += 1
      2.times do
        write, read = sent ? [true, false] : [false, true]
        rs, ws, = socket.select rs: read, ws: write
        break unless rs or ws

        if ws
          msg = Network::Packet.new chunks: file.chunks, seek: seek,
                                    len: chunk.length, data: chunk
          socket.send msg.to_binary_s
          sent = false
        end

        if rs
          msg, = socket.recv(3)
          sent = true if msg == Network::ACK
        end
      end
    end
    socket.send Network::FIN
  end
end
