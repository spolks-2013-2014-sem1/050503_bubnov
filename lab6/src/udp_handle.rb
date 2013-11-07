require_relative '../../spolks_lib/network'

def udp_handle(opts)
  count = 0
  threads = {}

  server = Network::DatagramSocket.new
  server.bind(Socket.sockaddr_in(opts[:port], ''))

  loop do
    rs, _ = IO.select([server], nil, nil)
    next unless rs

    rs.each do |s|
      data, who = s.recvfrom(Network::CHUNK_SIZE)
      who = who.ip_unpack

      unless threads[who]
        threads[who] = File.open("o#{count += 1}", 'w+')
      end

      if data.empty?
        threads[who].close
        threads.delete(who)
        next
      end

      threads[who].write(data)
    end
  end
ensure
  threads.each do |who, file|
    file.close
  end

  server.close if server
end
