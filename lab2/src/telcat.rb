require_relative 'local_server'

unless ARGV.first
  puts('Usage: telcat <port>')
  exit(-1)
end

server = LocalServer.new(ARGV.first)

begin
  server.accept
ensure
  server.close unless server.closed?
end