require 'securerandom'

require_relative '../../spolks_lib/network'
require_relative '../../spolks_lib/file'

def udp_server(opts)
  connections = {}

  Network::DatagramSocket.listen opts do |socket|
    loop do
      rs, = socket.select rs: true
      break unless rs

      data, who = socket.recv
      socket.send Network::ACK, who

      who = who.ip_unpack
      connections[who] = XIO::XFile.new "#{SecureRandom.hex}.ld" unless connections[who]
      file = connections[who]

      if data == Network::FIN
        file.close
        connections.delete(who)
        next
      end

      file.write data
    end
  end
end
