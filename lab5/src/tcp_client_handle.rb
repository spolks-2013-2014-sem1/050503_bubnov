require '../../spolks_lib/network'

MSG = '!'

def tcp_client_handle(options)
  file = File.open(options[:filepath], File::RDONLY)
  client = Network::StreamSocket.open(options[:ip], options[:port])

  ticker = Utils::Ticker.new(Network::PERIOD)
  sent = true
  transferred = 0

  loop do
    _, ws, = IO.select(nil, [client], nil, Network::TIMEOUT)

    break unless ws
    data, sent = file.read(Network::CHUNK_SIZE), false if sent

    if s = ws.shift
      break if not data
      sent = true unless s.send(data, 0) == 0
      s.send(MSG, Network::StreamSocket::MSG_OOB) if ticker.dump? and options[:verbose]

      transferred += data.length if sent
      puts(transferred) if options[:verbose]
    end
  end
ensure
  file.close if file
  client.close if client
end
