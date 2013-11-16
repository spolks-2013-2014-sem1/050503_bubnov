require 'fcntl'
require_relative '../../spolks_lib/network'

def tcp_server(opts)
  count = 0
  threads = {}

  server = Network::StreamSocket.new
  server.fcntl(Fcntl::F_SETFL, Fcntl::O_NONBLOCK)
  server.bind(Socket.sockaddr_in(opts[:port], ''))
  server.listen(5)

  loop do
    socket, = server.accept_nonblock rescue nil
    socket, = server.accept unless socket or !threads.empty?

    threads[socket] = {
        file: File.open("o#{count += 1}", 'w+'),
        recv: 0,
        read_oob: true,
    } if socket

    urgent_arr = []
    threads.each do |socket, data|
      urgent_arr.push(socket) if data[:read_oob]
    end

    rs, _, us = IO.select(threads.keys, nil, urgent_arr, Network::TIMEOUT)

    Array(us).each do |s|
      s.recv(1, Network::MSG_OOB)
      puts "#{s} #{threads[s][:recv]}" if opts.verbose?
      threads[s][:read_oob] = false
    end

    Array(rs).each do |s|
      attached = threads[s]
      data = s.recv(Network::CHUNK_SIZE)

      if data.empty?
        s.close
        attached[:file].close
        threads.delete(s)
        next
      end

      attached[:recv] += data.length
      attached[:read_oob] = true
      attached[:file].write(data)
    end
  end
ensure
  server.close if server
  threads.each do |socket, attached|
    socket.close if socket
    attached[:file].close if attached[:file]
  end
end
