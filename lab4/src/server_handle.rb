require_relative '../../spolks_lib/network'

def server_handle(opts)
  file = File.open(opts[:file], 'w+')
  server = Network::StreamSocket.new
  server.bind(Socket.sockaddr_in(opts[:port], ''))
  server.listen(3)

  rs, _ = IO.select([server], nil, nil, Network::TIMEOUT)
  return unless rs

  client, = server.accept
  recv = 0
  read_oob = true

  loop do
    urgent_arr = read_oob ? [client] : []
    rs, _, us = IO.select([client], nil, urgent_arr, Network::TIMEOUT)
    break unless rs or us

    us.each do |s|
      s.recv(1, Network::MSG_OOB)
      puts recv if opts.verbose?
      read_oob = false
    end

    rs.each do |s|
      data = s.recv(Network::CHUNK_SIZE)
      return if data.empty?

      recv += data.length
      read_oob = true
      file.write(data)
    end
  end
ensure
  file.close if file
  server.close if server
  client.close if client
end
