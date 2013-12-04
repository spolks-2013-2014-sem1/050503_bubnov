require 'securerandom'
require_relative '../../spolks_lib/network'


def tcp_server(opts)
  processes = []

  server = Network::StreamSocket.new
  server.bind(Socket.sockaddr_in(opts[:port], ''))
  server.listen(3)

  Signal.trap 'CLD' do
    pid = Process.wait(-1)
    processes.delete(pid)
  end

  loop do
    rs, _ = IO.select([server], nil, nil, Network::TIMEOUT)
    break unless rs

    socket, = server.accept

    processes << fork do
      begin
        server.close
        file = File.open("#{SecureRandom.hex}.ld", 'w+')
        recv = 0
        has_oob = true

        loop do
          urgent_arr = has_oob ? [socket] : []
          rs, _, us = IO.select([socket], nil, urgent_arr, Network::TIMEOUT)
          break unless rs or us

          us.each do |s|
            s.recv(1, Network::MSG_OOB)
            puts "#{s} #{recv}" if opts.verbose?
            has_oob = false
          end

          rs.each do |s|
            data = s.recv(Network::CHUNK_SIZE)
            exit if data.empty?

            recv += data.length
            has_oob = true

            file.write(data)
          end
        end

      ensure
        file.close if file
        socket.close if socket
      end
    end

    socket.close if socket
  end
ensure
  server.close if server
end
