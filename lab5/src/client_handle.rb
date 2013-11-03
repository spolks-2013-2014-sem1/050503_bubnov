require_relative '../../spolks_lib/network'

MSG = '!'

def client_handle(opts)
  sock = if opts.udp? then :udp else :tcp end

  file = File.open(opts[:file], File::RDONLY)
  client = Network::AbstractSocket.open(sock)
  client.connect(Socket.sockaddr_in(opts[:port], opts[:host]))

  sent_oob = 0
  sent = true
  transferred = 0

  loop do
    sent_oob += 1 if opts.verbose? && !opts.udp?
    _, ws, = IO.select(nil, [client], nil, Network::TIMEOUT)

    break unless ws
    data, sent = file.read(Network::CHUNK_SIZE), false if sent

    ws.each do |s|
      return unless data
      sent = true unless s.send(data, 0) == 0

      if opts.verbose? && !opts.udp? && sent_oob % 64 == 0
        sent_oob = 0
        s.send(MSG, Network::MSG_OOB)
      end

      transferred += data.length if sent
      puts(transferred) if opts.verbose? && !opts.udp?
    end
  end
ensure
  file.close if file
  client.close if client
end
