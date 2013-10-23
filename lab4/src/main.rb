require '../../spolks_lib/utils'
require '../../spolks_lib/net'
require 'io/console'

MSG = '!'.chr

server, client, income = nil

options = Utils::ArgumentParser.new
options.parse!

handle = Utils::Handle.new
handle.assign 'TERM', 'INT' do
  server.shutdown(Net::TCPSocket::SHUT_RDWR) if server
  client.shutdown(Net::TCPSocket::SHUT_RDWR) if client
  exit
end

if options.file_server?
  begin

    File.open(options[:filepath], File::CREAT|File::TRUNC|File::WRONLY) do |file|
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

          file.write(data)
        end
      end


    end
  ensure
    server.close if server
    income.close if income
  end

elsif options.file_client?
  begin

    File.open(options[:filepath], File::RDONLY) do |file|
      client = Net::TCPSocket.new
      sockaddr = Net::TCPSocket.sockaddr_in(options[:port], options[:ip])
      client.connect(sockaddr)

      ticker = Utils::Pendulum.new(Net::PERIOD)
      sent = true
      transferred = 0

      loop do
        _, has_write, = IO.select(nil, [client], nil, Net::TIMEOUT)

        break unless has_write
        data, sent = file.read(Net::CHUNK_SIZE), false if sent

        if s = has_write.shift
          break if not data
          sent = true unless s.send(data, 0) == 0
          s.send(MSG, Net::TCPSocket::MSG_OOB) if ticker.dump? and options[:verbose]

          transferred += data.length if sent
          IO.console.puts(transferred) if options[:verbose]
        end
      end
    end
  ensure
    client.close if client
  end
else
  puts options.help
end
