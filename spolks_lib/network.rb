require 'socket'

module Network
  include Socket::Constants

  CHUNK_SIZE = 4096
  TIMEOUT = 10
  INADDR_ANY = ''

  class StreamSocket < Socket
    def initialize
      super(Socket::AF_INET, Socket::SOCK_STREAM, 0)
      setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, true)
    end
  end

  class DatagramSocket < Socket
    def initialize
      super(Socket::AF_INET, Socket::SOCK_DGRAM, 0)
      setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, true)
      setsockopt(Socket::SOL_SOCKET, Socket::SO_RCVBUF, CHUNK_SIZE * 4)
      setsockopt(Socket::SOL_SOCKET, Socket::SO_SNDBUF, CHUNK_SIZE * 8)
    end
  end

  class AbstractSocket
    @@sockets = {
        tcp: StreamSocket,
        udp: DatagramSocket,
    }

    def self.open(what)
      @@sockets[what].new
    end
  end
end