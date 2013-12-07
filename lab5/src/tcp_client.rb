require_relative '../../spolks_lib/network'
require_relative '../../spolks_lib/file'

def tcp_client(opts)
  Network::StreamSocket.open opts do |sock|
    XIO::XFile.read opts do |file, chunk|
      _, ws, = sock.select ws: true
      break unless ws
      sock.send chunk
      if opts.verbose?
        sock.send_oob
        puts file.pos
      end
    end
  end
end
