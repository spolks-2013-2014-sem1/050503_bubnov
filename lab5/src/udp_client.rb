require_relative '../../spolks_lib/network'

def udp_client(opts)
  sent = true

  Network::DatagramSocket.open opts do |socket|
    XIO::XFile.read opts do |file, chunk|
      2.times do
        write, read = sent ? [true, false] : [false, true]
        rs, ws, = socket.select rs: read, ws: write
        break unless rs or ws

        if ws
          socket.send chunk
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
