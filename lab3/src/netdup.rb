require '../../spolks_lib/local_server'
require 'optparse'

options = {}

optparse = OptionParser.new do |opts|
  opts.banner = 'Usage: netdup.rb [options] [ip] <port> < | > file'

  options[:listen] = false
  opts.on('-l', 'Listen port') do
    options[:listen] = true
  end

  opts.on(/^([0-9]{1,3}\.){3}[0-9]{1,3}$/) do |ip|
    options[:ip] = ip
  end

  opts.on(/^[0-9]+$/) do |port|
    options[:port] = port
  end

  opts.on('-h', '--help', 'Display this screen') do
    puts opts
    exit
  end
end

optparse.parse!


if options[:listen] and options[:port]
  begin
    server = LocalServer.new(options[:port])
    client = server.accept

    STDIN.each do |data|
      client.write(data)
    end

  ensure
    server.close if server
    client.close if client
  end

elsif not options[:listen] and options[:ip] and options[:port]
  begin
    client = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, 0)
    sockaddr = Socket::sockaddr_in(options[:port], options[:ip])
    client.connect(sockaddr)

    while data = client.gets
      STDOUT.write(data)
    end

  ensure
    client.close if client
  end
else
  puts optparse.help
  exit
end
