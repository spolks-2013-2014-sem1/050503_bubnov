require_relative '../../spolks_lib/network'

MSG = '!'


def client_handle(opts)
  file = File.open(opts[:file], 'r')
  client = opts[:udp] ? Network::DatagramSocket.new : Network::StreamSocket.new
  client.connect(Socket.sockaddr_in(opts[:port], opts[:host]))

  sent_oob = 0
  sent = true
  transferred = 0

  loop do
    _, ws, = IO.select(nil, [client], nil, Network::TIMEOUT)

    break unless ws
    data, sent = file.read(Network::CHUNK_SIZE), false if sent

    ws.each do |s|
      return unless data
      sent = true unless s.send(data, 0) == 0

      unless opts.udp?
        sent_oob += 1 if opts.verbose?

        if opts.verbose? && sent_oob % 64 == 0
          sent_oob = 0
          s.send(MSG, Network::MSG_OOB)
        end

        transferred += data.length if sent
        puts(transferred) if opts.verbose?
      end
    end
  end
ensure
  file.close if file
  client.close if client
end
