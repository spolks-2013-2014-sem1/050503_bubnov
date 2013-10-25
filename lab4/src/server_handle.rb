require '../../spolks_lib/network'

def server_handle(options)
  file = File.open(options[:filepath], File::CREAT|File::TRUNC|File::WRONLY)
  server = Network::StreamServer.new(Network::INADDR_ANY, options[:port])

  client, = server.accept
  recv = 0
  read_oob = true

  loop do
    urgent_arr = read_oob ? [client] : []
    rs, _, us = IO.select([client], nil, urgent_arr, Network::TIMEOUT)

    if s = us.shift
      s.recv(1, Network::StreamSocket::MSG_OOB)
      puts recv if options[:verbose]
      read_oob = false
    end

    if s = rs.shift
      data = s.recv(Network::CHUNK_SIZE)

      break if data.empty?
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
