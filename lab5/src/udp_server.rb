require_relative '../../spolks_lib/network'

def udp_server(opts)
  Network::DatagramSocket.listen opts do |socket|
    XIO::XFile.write opts do |file|
      loop do
        rs, = socket.select rs: true
        break unless rs

        data, who = socket.recv
        socket.send Network::ACK, who
        break if data.empty? or data == Network::FIN
        file.write data
      end
    end
  end
end
