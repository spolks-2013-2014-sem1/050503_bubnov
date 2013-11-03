require 'slop'
require_relative 'client_handle'
require_relative 'server_handle'

opts = Slop.parse(help: true) do
  on :g, :host=, 'Hostname'
  on :p, :port=, 'Port'
  on :f, :file=, 'Filename'
  on :v, :verbose, 'Enable verbose mode'
  on :l, :listen, 'Listen for incoming connections'
end

%w(TERM INT).each do |signal|
  Signal.trap signal do
    exit
  end
end

if opts.listen? && opts.file?
  server_handle(opts)
elsif !opts.listen? && opts.file?
  client_handle(opts)
else
  puts opts.help
end
