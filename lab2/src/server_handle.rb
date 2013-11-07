require_relative '../../spolks_lib/network'

def server_handle(opts)
  server = Network::StreamSocket.new
  server.bind(Socket.sockaddr_in(opts[:port], ''))
  server.listen(3)

  client, = server.accept

  loop do
    data = client.recv(Network::CHUNK_SIZE)

    break if data.empty?
    client.send(data, 0)
  end
ensure
  server.close if server
  client.close if client
end
