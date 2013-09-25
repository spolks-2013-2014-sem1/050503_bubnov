require '../../spolks_lib/utils'
require '../../spolks_lib/net'
require '../../spolks_lib/secure'
require_relative 'sockatmark'
require 'io/console'

MSG = '!'.chr

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
    ticker = Utils::Pendulum.new(1)
    send = 0

    while data = STDIN.read(Net::CHUNK_SIZE)
      income.send(MSG, Net::TCPSocket::MSG_OOB) if ticker.dump?
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
    read_oob = true
    data = ''

    loop do
      urgent_arr = read_oob ? [client] : []
      has_regular, _, has_urgent = IO.select([client], nil, urgent_arr, nil)


      if s = has_urgent.shift
        oob = s.recv(100, Net::TCPSocket::MSG_OOB)

        IO.console.puts(oob) if not oob.empty? and options[:verbose]
        read_oob = false
      end

      if s = has_regular.shift
        recv += data.length

        read_oob = true
        break if data.empty?

        STDOUT.write(data)
      end
    end

  ensure
    client.close if client
  end
else
  puts options.help
  exit
end
