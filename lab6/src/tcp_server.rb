require 'securerandom'

require_relative '../../spolks_lib/network'
require_relative '../../spolks_lib/file'

def tcp_server(opts)
  connections = {}

  Network::StreamServer.listen opts do |server|
    loop do
      rs, _, es = Network::StreamSocket.select(connections.keys + [server],
                                               nil, connections.keys)
      break unless rs or es

      if rs.include? server
        rs.delete(server)
        s, = server.accept
        connections[s] = XIO::XFile.new "#{SecureRandom.hex}.ld"
      end

      es.each do |s|
        s.recv_oob
        file = connections[s]
        puts file.size if opts.verbose?
      end

      rs.each do |s|
        chunk = s.recv
        file = connections[s]
        file.write chunk

        if chunk.empty?
          s.close
          file.close
          connections.delete(s)
        end
      end
    end
  end

ensure
  connections.each do |sock, file|
    sock.close if sock
    file.close if file
  end
end
