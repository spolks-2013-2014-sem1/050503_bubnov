require '../../spolks_lib/net'
require '../../spolks_lib/utils'

options = Utils::ArgumentParser.new
options.parse!

server, client = nil

handle = Utils::Handle.new
handle.assign 'TERM', 'INT' do
  puts ''
  server.shutdown(Net::TCPSocket::SHUT_RDWR) if server
  client.shutdown(Net::TCPSocket::SHUT_RDWR) if client
  exit
end

if options.server?
  begin
    server = Net::TCPSocket.new
    sockaddr = Net::TCPSocket.sockaddr_in(options[:port], Net::INADDR_ANY)
    client, = server.tie(sockaddr)

    loop do
      data = client.recv(Net::CHUNK_SIZE)

      break if data.empty?
      client.send(data, 0)
    end
  ensure
    server.close if server
  end
else
  puts options.help
end