require_relative '../../spolks_lib/network'

def udp_server(opts)
  count = 0
  threads = {}

  server = Network::DatagramSocket.new
  server.bind(Socket.sockaddr_in(opts[:port], ''))

  loop do
    rs, _ = IO.select([server], nil, nil, Network::TIMEOUT)
    break unless rs

    rs.each do |s|
      data, who = s.recvfrom(Network::CHUNK_SIZE)
      s.send(Network::ACK, 0, who)

      who = who.ip_unpack
      threads[who] = File.open("o#{count += 1}", 'w+') unless threads[who]

      if data == Network::FIN
        threads[who].close
        threads.delete(who)
        next
      end

      threads[who].write(data)
    end
  end
ensure
  server.close if server
  threads.each do |who, file|
    file.close if file
  end
end
