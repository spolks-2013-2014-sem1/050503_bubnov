require 'socket'

module Net
  CHUNK_SIZE = 65535

  class TCPSocket < Socket
    def initialize
      super(Socket::AF_INET, Socket::SOCK_STREAM, 0)
      setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, true)
    end
  end

  class LocalServer
    def initialize(port)
      @socket = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, 0)
      @socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, true)

      sockaddr = Socket.sockaddr_in(port, '')
      @socket.bind(sockaddr)
      @socket.listen(1)
    end

    def accept
      income_socket, = @socket.accept
      income_socket
    end

    def close
      @socket.close
    end

    def closed?
      @socket.closed?
    end

    def shutdown(*how)
      @socket.shutdown(*how)
    end
  end
end