require_relative '../../spolks_lib/network'

def udp_client(opts)
  file = File.open(opts[:file], 'r')
  client = Network::DatagramSocket.new
  client.connect(Socket.sockaddr_in(opts[:port], opts[:host]))

  chunks = file.size / Network::CHUNK_SIZE
  chunks += 1 if file.size % Network::CHUNK_SIZE

  sent = true
  done = false
  seek = -1

  loop do
    wr_arr, rd_arr = sent ? [[client], []] : [[], [client]]
    rs, ws, = IO.select(rd_arr, wr_arr, nil, Network::TIMEOUT)

    break unless rs or ws
    break if sent and done

    data, sent, seek = file.read(Network::CHUNK_SIZE),
        false, seek + 1 if sent

    ws.each do |s|
      msg = Network::Packet.new(seek: seek, chunks: chunks,
                                len: data.length, data: data) if data
      done, = data ?
          [false, s.send(msg.to_binary_s, 0)] :
          [true, s.send(Network::FIN, 0)]
    end

    rs.each do |s|
      sent = true if s.recv(3) == Network::ACK
    end
  end
ensure
  file.close if file
  client.close if client
end
