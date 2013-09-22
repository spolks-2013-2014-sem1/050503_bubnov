require '../../spolks_lib/local_server'
require '../../spolks_lib/argument_parser'
require 'io/console'

class InfoDump
  def initialize(bound, step = 1)
    @yielder = 0
    @bound = bound
    @step = step
  end

  def dump?
    @yielder += @step

    if @yielder == @bound
      @yielder = 0
      true
    else
      false
    end
  end
end

def safe
  yield
rescue Errno::EINVAL
end

CHUNK_SIZE = 65535
OOB_MSG = 'o'

options = ArgumentParser.new
options.parse!

if options[:listen] and options[:port]
  begin
    server = LocalServer.new(options[:port])
    client = server.accept
    yielder = InfoDump.new(3)
    send = 0

    while data = STDIN.read(CHUNK_SIZE)
      client.send(OOB_MSG, Socket::MSG_OOB) if yielder.dump?
      client.send(data, 0)

      IO.console.puts(send += data.length) if options[:verbose]
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

    recv = 0

    loop do
      safe do
        oob = client.recv(1, Socket::MSG_OOB)
        IO.console.puts(recv) if not oob.empty? and options[:verbose]
      end

      data = client.recv(CHUNK_SIZE)
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
