require 'slop'
require_relative '../../spolks_lib/stream_socket'
require_relative '../../spolks_lib/stream_server'
require_relative '../../spolks_lib/file'

opts = Slop.parse(help: true) do
  on :g, :host=, 'Hostname'
  on :p, :port=, 'Port'
  on :f, :file=, 'Filename'
  on :l, :listen, 'Listen for incoming connections'
end

%w(TERM INT).each do |signal|
  Signal.trap signal do
    exit
  end
end

if opts.listen? && opts.file?
  Network::StreamServer.listen opts do |server|
    rs, = server.select rs: true
    break unless rs
    client, = server.accept

    XIO::XFile.write opts do |file|
      loop do
        rs, = client.select rs: true
        break unless rs
        chunk = client.recv
        break if chunk.empty?
        file.write chunk
      end
    end
  end
elsif !opts.listen? && opts.file?
  Network::StreamSocket.open opts do |sock|
    XIO::XFile.read opts do |file, chunk|
      _, ws, = sock.select ws: true
      break unless ws
      sock.send chunk
    end
  end
else
  puts opts
end
