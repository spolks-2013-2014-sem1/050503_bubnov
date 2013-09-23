require '../../spolks_lib/utils'
require '../../spolks_lib/net'
require '../../spolks_lib/secure'
require 'io/console'

MSG = 13.chr

server, client = nil

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
    ticker = Utils::Pendulum.new(0)
    send = 0

    while data = STDIN.read(Net::CHUNK_SIZE)
      income.send(MSG, Net::TCPSocket::MSG_OOB) and IO.console.puts('true') if ticker.dump?
      income.send(data, 0)

      IO.console.puts(send += data.length) if options[:verbose]
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

    recv = 0

    Thread.new do
      loop do
        Secure.safe do
          client.recv(MSG.length, Net::TCPSocket::MSG_OOB)
          IO.console.puts(recv)
        end
      end
    end

    loop do
      data = client.recv(Net::CHUNK_SIZE)
      recv += data.length

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
