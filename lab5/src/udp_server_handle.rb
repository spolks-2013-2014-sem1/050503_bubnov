require '../../spolks_lib/network'

def udp_server_handle(options)
  file = File.open(options[:filepath], File::CREAT|File::TRUNC|File::WRONLY)
  server = Network::DatagramSocket.new(Network::INADDR_ANY, options[:port])

  loop do
    rs, _ = IO.select([server], nil, nil, Network::TIMEOUT)
    break unless rs

    if s = rs.shift
      data = s.recv(Network::CHUNK_SIZE)
      break if data.empty?

      file.write(data)
    end
  end
ensure
  file.close if file
  server.close if server
end
