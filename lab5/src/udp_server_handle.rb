require_relative '../../spolks_lib/network'

def udp_server_handle(opts)
  file = File.open(opts[:file], File::CREAT|File::TRUNC|File::WRONLY)
  server = Network::AbstractSocket.open(:udp)
  server.bind(Socket.sockaddr_in(opts[:port], Network::INADDR_ANY))

  loop do
    rs, _ = IO.select([server], nil, nil, Network::TIMEOUT)
    break unless rs

    rs.each do |s|
      data = s.recv(Network::CHUNK_SIZE)
      return if data.empty?

      file.write(data)
    end
  end
ensure
  file.close if file
  server.close if server
end
