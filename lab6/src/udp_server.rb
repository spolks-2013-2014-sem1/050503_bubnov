require 'securerandom'
require_relative '../../spolks_lib/stream_socket'

def udp_server(opts)
  connections = {}

  server = Network::DatagramSocket.new
  server.bind(Socket.sockaddr_in(opts[:port], ''))

  loop do
    rs, _ = IO.select([server], nil, nil, Network::TIMEOUT)
    break unless rs

    rs.each do |s|
      data, who = s.recvfrom(Network::CHUNK_SIZE)
      s.send(Network::ACK, 0, who)

      who = who.ip_unpack
      connections[who] = File.open("#{SecureRandom.hex}.ld", 'w+') unless connections[who]

      if data == Network::FIN
        connections[who].close
        connections.delete(who)
        next
      end

      connections[who].write(data)
    end
  end
ensure
  server.close if server
  connections.each do |who, file|
    file.close if file
  end
end
