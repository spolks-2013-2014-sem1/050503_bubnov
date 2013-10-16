require '../../spolks_lib/utils'
require '../../spolks_lib/net'

client, server, income = nil

options = Utils::ArgumentParser.new
options.parse!

handle = Utils::Handle.new
handle.assign 'TERM', 'INT' do
  server.shutdown(Net::TCPSocket::SHUT_RDWR) if server
  client.shutdown(Net::TCPSocket::SHUT_RDWR) if client
  exit
end

if options.file_server?
  File.open(options[:filepath], File::CREAT|File::TRUNC|File::WRONLY) do |file|
    begin
      server = Net::TCPSocket.new
      sockaddr = Net::TCPSocket.sockaddr_in(options[:port], Net::INADDR_ANY)
      income, = server.tie(sockaddr)

      loop do
        has_regular, = IO.select([income], nil, nil, Net::TIMEOUT)
        break unless has_regular

        if s = has_regular.shift
          data = s.recv(Net::CHUNK_SIZE)
          break if data.empty?

          file.write(data)
        end
      end
    ensure
      server.close if server
      income.close if income
    end
  end

elsif options.file_client?
  File.open(options[:filepath], File::RDONLY) do |file|
    begin
      client = Net::TCPSocket.new
      sockaddr = Net::TCPSocket.sockaddr_in(options[:port], options[:ip])
      client.connect(sockaddr)

      sent = true

      loop do
        _, has_write, = IO.select(nil, [client], nil, Net::TIMEOUT)

        break unless has_write
        data, sent = file.read(Net::CHUNK_SIZE), false if sent

        if s = has_write.shift
          break unless data
          sent = true unless s.send(data, 0) == 0
        end
      end
    ensure
      client.close if client
    end
  end

else
  puts options.help
end
