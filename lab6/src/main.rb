require 'slop'
require_relative 'tcp_handle'
require_relative 'udp_handle'

opts = Slop.parse(help: true) do
  on :g, :host=, 'Hostname'
  on :p, :port=, 'Port'
  on :f, :file=, 'Filename'
  on :v, :verbose, 'Enable verbose mode'
  on :u, :udp, 'Use UDP instead of TCP'
  on :l, :listen, 'Listen for incoming connections'
end

%w(TERM INT).each do |signal|
  Signal.trap signal do
    exit
  end
end

if opts.listen?
  if opts.udp?
    udp_server_handle(opts)
  else
    tcp_server_handle(opts)
  end
elsif !opts.listen? && opts.file?
  if opts.udp?
    udp_client_handle(opts)
  else
    tcp_client_handle(opts)
  end
else
  puts opts
end


