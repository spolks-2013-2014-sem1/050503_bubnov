require 'slop'
require_relative 'server_handle'

opts = Slop.parse(help: true) do
  on :p, :port=, 'Port'
end

%w(TERM INT).each do |signal|
  Signal.trap signal do
    exit
  end
end

if opts.port?
  server_handle(opts)
else
  puts opts.help
end
