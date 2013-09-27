require '../../spolks_lib/net'
require '../../spolks_lib/utils'
require '../../spolks_lib/secure'

options = Utils::ArgumentParser.new
options.parse!

server, client = nil

handle = Secure::Handle.new
handle.assign 'TERM', 'INT' do
  puts ''
  server.shutdown(Net::TCPSocket::SHUT_RDWR)
  client.shutdown(Net::TCPSocket::SHUT_RDWR)
  exit
end

if options[:listen] and options[:port]
  begin
    server = Net::TCPSocket.new
    sockaddr = Net::TCPSocket.sockaddr_in(options[:port], '')
    client, = server.tie(sockaddr)

    loop do
      data = client.recv(Net::CHUNK_SIZE)

      break if data.empty?
      client.send(data, 0)
    end

  ensure
    client.close if client
    server.close if server
  end
else
  options.help
end