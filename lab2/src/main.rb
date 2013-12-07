require 'slop'
require_relative '../../spolks_lib/network'

opts = Slop.parse(help: true) do
  on :p, :port=, 'Port'
end

%w(TERM INT).each do |signal|
  Signal.trap signal do
    exit
  end
end

if opts.port?
  Network::StreamServer.listen opts do |server|
    break unless server.select rs: true
    client, = server.accept

    loop do
      rs, = client.select rs: true
      break unless rs
      chunk = client.recv
      break if chunk.empty?
      client.send chunk
    end
  end
else
  puts opts
end
