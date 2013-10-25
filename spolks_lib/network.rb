require 'socket'

module Network
  CHUNK_SIZE = 16380
  PERIOD = 64
  TIMEOUT = 10
  INADDR_ANY = ''

  class StreamServer < Socket
    def initialize(hostname, port)
      super(Socket::AF_INET, Socket::SOCK_STREAM, 0)
      setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, true)
      bind(Socket.sockaddr_in(port, hostname))
      listen(3)
    end
  end

  class StreamSocket < Socket
    def initialize(hostname, port)
      super(Socket::AF_INET, Socket::SOCK_STREAM, 0)
      setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, true)
      connect(Socket.sockaddr_in(port, hostname))
    end
  end

  class DatagramSocket < Socket
    def initialize(hostname, port)
      super(Socket::AF_INET, Socket::SOCK_DGRAM, 0)
      setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, true)
      bind(Socket.sockaddr_in(port, hostname))
    end
  end
end