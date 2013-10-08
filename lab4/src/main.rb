require '../../spolks_lib/utils'
require '../../spolks_lib/net'
require '../../spolks_lib/secure'
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
    server = Net::TCPSocket.new
    sockaddr = Net::TCPSocket.sockaddr_in(options[:port], Net::INADDR_ANY)
    income, = server.tie(sockaddr)

    recv = 0
    read_oob = true

    loop do
      urgent_arr = read_oob ? [income] : []
      has_regular, _, has_urgent = IO.select([income], nil, urgent_arr, Net::TIMEOUT)

      if s = has_urgent.shift
        s.recv(1, Net::TCPSocket::MSG_OOB)
        IO.console.puts(recv) if options[:verbose]
        read_oob = false
      end

      if s = has_regular.shift
        data = s.recv(Net::CHUNK_SIZE)

        break if data.empty?
        recv += data.length
        read_oob = true
        STDOUT.write(data)
      end
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

    ticker = Utils::Pendulum.new(15)
    send = 0

    loop do
      data = STDIN.read(Net::CHUNK_SIZE)

      break if not data
      client.send(data, 0)
      client.send(MSG, Net::TCPSocket::MSG_OOB) if ticker.dump? and options[:verbose]

      send += data.length
      IO.console.puts(send) if options[:verbose]
    end

  ensure
    client.close if client
  end
else
  puts options.help
end
