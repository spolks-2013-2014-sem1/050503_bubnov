require_relative '../../spolks_lib/network'

def tcp_server_handle(opts)
  file = File.open(opts[:file], File::CREAT|File::TRUNC|File::WRONLY)
  server = Network::AbstractSocket.open(:tcp)
  server.bind(Socket.sockaddr_in(opts[:port], Network::INADDR_ANY))
  server.listen(3)

  client, = server.accept
  recv = 0
  read_oob = true

  loop do
    urgent_arr = read_oob ? [client] : []
    rs, _, us = IO.select([client], nil, urgent_arr, Network::TIMEOUT)

    us.each do |s|
      s.recv(1, Network::StreamSocket::MSG_OOB)
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
