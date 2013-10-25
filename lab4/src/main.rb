require '../../spolks_lib/utils'
require_relative 'client_handle'
require_relative 'server_handle'

options = Utils::ArgumentParser.new
options.parse!

%w(TERM INT).each do |signal|
  Signal.trap signal do
    exit
  end
end

if options.file_server?
  server_handle(options)
elsif options.file_client?
  client_handle(options)
else
  puts options.help
end
