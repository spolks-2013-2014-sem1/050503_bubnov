require '../../spolks_lib/net'
require '../../spolks_lib/secure'

unless ARGV.first
  puts('Usage: telcat <port>')
  exit
end

server, client = nil

handle = Secure::Handle.new
handle.assign 'TERM', 'INT' do
  puts ''
  server.shutdown(Net::TCPSocket::SHUT_RDWR)
  exit
end

begin
  server = Net::LocalServer.new(ARGV.first)
  client = server.accept

  while data = client.gets
    client.write(data)
  end

ensure
  client.close if client
  server.close if server
end