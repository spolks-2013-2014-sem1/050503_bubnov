require '../../spolks_lib/local_server'

unless ARGV.first
  puts('Usage: telcat <port>')
  exit(-1)
end

begin
  server = LocalServer.new(ARGV.first)
  client = server.accept

  while data = client.gets
    client.write(data)
  end

ensure
  client.close if client
  server.close if server
end