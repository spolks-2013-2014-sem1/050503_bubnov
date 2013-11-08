require_relative '../../spolks_lib/network'

def udp_server(opts)
  file = File.open(opts[:file], 'w+')
  server = Network::DatagramSocket.new
  server.bind(Socket.sockaddr_in(opts[:port], ''))

  loop do
    rs, _ = IO.select([server], nil, nil, Network::TIMEOUT)
    break unless rs

    rs.each do |s|
      data, who = s.recvfrom(Network::CHUNK_SIZE)
      s.send(Network::ACK, 0, who)
      return if data.empty? or data == Network::FIN
      file.write(data)
    end
  end
ensure
  file.close if file
  server.close if server
end
