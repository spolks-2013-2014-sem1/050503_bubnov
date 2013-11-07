require_relative '../../spolks_lib/network'

def server_handle(opts)
  file = File.open(opts[:file], 'w+')
  server = Network::StreamSocket.new
  server.bind(Socket.sockaddr_in(opts[:port], ''))
  server.listen(3)

  client, = server.accept

  loop do
    rs, _ = IO.select([client], nil, nil, Network::TIMEOUT)
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
  client.close if client
end
