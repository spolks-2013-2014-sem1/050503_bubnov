require_relative '../../spolks_lib/network'

MSG = '!'

def client_handle(opts)
  file = File.open(opts[:file], File::RDONLY)
  client = Network::StreamSocket.new
  client.connect(Socket.sockaddr_in(opts[:port], opts[:host]))

  send_oob = 0
  sent = true
  transferred = 0

  loop do
    send_oob += 1 if opts.verbose?
    _, ws, = IO.select(nil, [client], nil, Network::TIMEOUT)

    break unless ws
    data, sent = file.read(Network::CHUNK_SIZE), false if sent

    ws.each do |s|
      return if not data
      sent = true unless s.send(data, 0) == 0

      if send_oob % 64 == 0 && opts.verbose?
        send_oob = 0
        s.send(MSG, Network::StreamSocket::MSG_OOB)
      end

      transferred += data.length if sent
      puts(transferred) if opts.verbose?
    end
  end
ensure
  file.close if file
  client.close if client
end