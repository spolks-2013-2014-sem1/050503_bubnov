require_relative '../../spolks_lib/network'

def client_handle(opts)
  file = File.open(opts[:file], File::RDONLY)
  client = Network::StreamSocket.new
  client.connect(Socket.sockaddr_in(opts[:port], opts[:host]))
  sent = true

  loop do
    _, ws, = IO.select(nil, [client], nil, Network::TIMEOUT)

    break unless ws
    data, sent = file.read(Network::CHUNK_SIZE), false if sent

    ws.each do |s|
      return unless data
      sent = true unless s.send(data, 0) == 0
    end
  end
ensure
  file.close if file
  client.close if client
end
