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
    server = Net::TCPSocket.new
    sockaddr = Net::TCPSocket.sockaddr_in(options[:port], '')
    income, = server.tie(sockaddr)

    loop do
      data = income.recv(Net::CHUNK_SIZE)
      break if data.empty?
      STDOUT.write(data)
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
      data = STDIN.read(Net::CHUNK_SIZE)
      break if not data
      client.send(data, 0)
    end

  ensure
    client.close if client
  end
else
  puts options.help
end
