require '../../spolks_lib/utils'
require_relative 'tcp_client_handle'
require_relative 'tcp_server_handle'
require_relative 'udp_client_handle'
require_relative 'udp_server_handle'

options = Utils::ArgumentParser.new
options.parse!

%w(TERM INT).each do |signal|
  Signal.trap signal do
    exit
  end
end

if options.file_server?
  if options[:tcp]
    tcp_server_handle(options)
  else
    udp_server_handle(options)
  end
elsif options.file_client?
  if options[:tcp]
    tcp_client_handle(options)
  else
    udp_client_handle(options)
  end
else
  puts options.help
end


