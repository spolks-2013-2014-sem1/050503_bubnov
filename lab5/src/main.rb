require '../../spolks_lib/utils'
require '../../spolks_lib/net'
require 'io/console'

MSG = '!'.chr

server, client = nil

options = Utils::ArgumentParser.new
options.parse!

handle = Utils::Handle.new
handle.assign 'TERM', 'INT' do
  server.close if server
  client.close if client
  exit
end

if options.file_server?
  begin
    server = Net::AbstractSocket.factory(options[:type])
    sockaddr = Net::AbstractSocket.sockaddr_in(options[:port], Net::INADDR_ANY)
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

elsif options.file_client?
  begin
    client = Net::AbstractSocket.factory(options[:type])
    sockaddr = Net::AbstractSocket.sockaddr_in(options[:port], options[:ip])
    client.connect(sockaddr)

    ticker = Utils::Pendulum.new(15)
    send = 0

    loop do
      data = STDIN.read(Net::CHUNK_SIZE)

      break if not data
      client.send(data, 0)
      server.send(MSG, Net::TCPSocket::MSG_OOB) if ticker.dump? and options[:verbose]

      send += data.length
      IO.console.puts(send) if options[:verbose]
    end

  ensure
    client.close if client
  end
else
  puts options.help
end

