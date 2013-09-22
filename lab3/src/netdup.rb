require '../../spolks_lib/local_server'
require '../../spolks_lib/argument_parser'
require 'io/console'

CHUNK_SIZE = 65535

options = ArgumentParser.new
options.parse!

if options[:listen] and options[:port]
  begin
    server = LocalServer.new(options[:port])
    client = server.accept

    while data = STDIN.read(CHUNK_SIZE)
      client.send(data, 0)
    end

  ensure
    server.close if server
    client.close if client
  end

elsif not options[:listen] and options[:ip] and options[:port]
  begin
    client = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, 0)
    sockaddr = Socket.sockaddr_in(options[:port], options[:ip])
    client.connect(sockaddr)

    loop do
      data = client.recv(CHUNK_SIZE)

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
