require_relative '../../spolks_lib/network'

def udp_handle(opts)
  file = File.open(opts[:file], 'w+')
  server = Network::DatagramSocket.new
  server.bind(Socket.sockaddr_in(opts[:port], ''))

  loop do
    rs, _ = IO.select([server], nil, nil, Network::TIMEOUT)
    break unless rs

    rs.each do |s|
      data = s.recv(Network::CHUNK_SIZE)
      return if data.empty?

      file.write(data)
    end
  end
ensure
  file.close if file
  server.close if server
end
