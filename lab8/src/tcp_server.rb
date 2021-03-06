require 'securerandom'

require_relative '../../spolks_lib/network'
require_relative '../../spolks_lib/file'

def tcp_server(opts)
  processes = []

  Signal.trap 'CLD' do
    pid = Process.wait(-1)
    processes.delete(pid)
  end

  Network::StreamServer.listen opts do |server|
    loop do
      rs, = server.select rs: true
      break unless rs
      client, = server.accept

      processes << fork do
        server.close

        XIO::XFile.write file: "#{SecureRandom.hex}.ld" do |file|
          loop do
            rs, _, es = client.select rs: true, es: true
            break unless rs or es

            if es
              client.recv_oob
              puts file.size if opts.verbose?
            end

            if rs
              chunk = client.recv
              break if chunk.empty?
              file.write chunk
            end
          end
        end
      end
    end
  end
end
