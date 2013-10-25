require '../../spolks_lib/network'

def server_handle(options)
  server = Network::StreamServer.new(Network::INADDR_ANY, options[:port])
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
