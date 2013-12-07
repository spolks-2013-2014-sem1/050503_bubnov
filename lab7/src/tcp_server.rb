require 'securerandom'

require_relative '../../spolks_lib/network'
require_relative '../../spolks_lib/file'

def tcp_server(opts)
  threads = []
  mutex = Mutex.new

  Network::StreamServer.listen opts do |server|
    loop do
      rs, = server.select rs: true
      break unless rs
      client, = server.accept

      threads << Thread.new do
        begin
          sock = client
          XIO::XFile.write file: "#{SecureRandom.hex}.ld" do |file|
            loop do
              rs, _, es = sock.select rs: true, es: true
              break unless rs or es

              if es
                sock.recv_oob
                puts file.size if opts.verbose?
              end

              if rs
                chunk = sock.recv
                break if chunk.empty?
                file.write chunk
              end
            end
          end
        ensure
          sock.close if sock
          mutex.synchronize do
            threads.delete(Thread.current)
          end
        end
      end
    end
  end
end
