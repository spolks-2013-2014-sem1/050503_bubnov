require 'socket'

module Net
  CHUNK_SIZE = 16380
  PERIOD = 64
  TIMEOUT = 10
  INADDR_ANY = ''

  module AbstractInterface
    class NotImplementedError < NoMethodError
    end

    def self.included(klass)
      klass.send(:include, AbstractInterface::Methods)
      klass.send(:extend, AbstractInterface::Methods)
    end

    module Methods
      def not_implemented(klass)
        raise AbstractInterface::NotImplementedError.new(
                  "#{klass.class.name} does not implement", nil)
      end
    end
  end

  class AbstractSocket < Socket
    include AbstractInterface

    @@sockets = {}

    def self.factory(what)
      @@sockets[what].new
    end

    def tie(sockaddr)
      not_implemented(self)
    end

    protected
    def self.register(type)
      @@sockets[type] = self
    end
  end

  class TCPSocket < AbstractSocket
    register :tcp

    def initialize
      super(Socket::AF_INET, Socket::SOCK_STREAM, 0)
      setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, true)
    end

    def tie(sockaddr)
      bind(sockaddr)
      listen(1)
      accept
    end
  end

  class UDPSocket < AbstractSocket
    register :udp

    def initialize
      super(Socket::AF_INET, Socket::SOCK_DGRAM, 0)
      setsockopt(Socket::SOL_SOCKET, Socket::SO_REUSEADDR, true)
    end

    def tie(sockaddr)
      bind(sockaddr)
      [self, sockaddr]
    end
  end
end