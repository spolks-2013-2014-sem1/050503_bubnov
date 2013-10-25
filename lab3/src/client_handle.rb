require '../../spolks_lib/network'

def client_handle(options)
  file = File.open(options[:filepath], File::RDONLY)
  client = Network::StreamSocket.new(options[:ip], options[:port])
  sent = true

  loop do
    _, ws, = IO.select(nil, [client], nil, Network::TIMEOUT)

    break unless ws
    data, sent = file.read(Network::CHUNK_SIZE), false if sent

    if s = ws.shift
      break unless data
      sent = true unless s.send(data, 0) == 0
    end
  end
ensure
  file.close if file
  client.close if client
end
