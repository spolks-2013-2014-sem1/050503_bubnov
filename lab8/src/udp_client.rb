require_relative '../../spolks_lib/network'

def udp_client(opts)
  file = File.open(opts[:file], 'r')
  client = Network::DatagramSocket.new
  client.connect(Socket.sockaddr_in(opts[:port], opts[:host]))

  sent = true
  done = false

  loop do
    wr_arr, rd_arr = sent ? [[client], []] : [[], [client]]
    rs, ws, = IO.select(rd_arr, wr_arr, nil, Network::TIMEOUT)

    break unless rs or ws
    break if sent and done

    data, sent = file.read(Network::CHUNK_SIZE), false if sent

    ws.each do |s|
      done, = data ?
          [false, s.send(data, 0)] :
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