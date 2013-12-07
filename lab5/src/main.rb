require 'slop'
require_relative 'tcp_client'
require_relative 'tcp_server'
require_relative 'udp_client'
require_relative 'udp_server'

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

if opts.listen? && opts.file?
  opts[:udp] ? udp_server(opts) : tcp_server(opts)
elsif !opts.listen? && opts.file?
  opts[:udp] ? udp_client(opts) : tcp_client(opts)
else
  puts opts
end
