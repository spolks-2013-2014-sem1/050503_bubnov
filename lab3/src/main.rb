require '../../spolks_lib/utils'
require '../../spolks_lib/net'
require '../../spolks_lib/secure'
require 'io/console'

client, server = nil

options = Utils::ArgumentParser.new
options.parse!

handle = Secure::Handle.new
handle.assign 'TERM', 'INT' do
  server.shutdown(Net::TCPSocket::SHUT_RDWR) if server
  client.shutdown(Net::TCPSocket::SHUT_RDWR) if client
  exit
end

if options[:listen] and options[:port]
  begin
    server = Net::LocalServer.new(options[:port])
    income = server.accept

    loop do
      data = STDIN.read(Net::CHUNK_SIZE)
      break if data.empty?
      income.send(data, 0)
    end

  ensure
    server.close if server
    income.close if income
  end

elsif not options[:listen] and options[:ip] and options[:port]
  begin
    client = Net::TCPSocket.new
    sockaddr = Net::TCPSocket.sockaddr_in(options[:port], options[:ip])
    client.connect(sockaddr)

    loop do
      data = client.recv(Net::CHUNK_SIZE)
      break if data.empty?
      STDOUT.write(data)
    end

  ensure
    client.close if client
  end
else
  puts options.help
  exit
end
