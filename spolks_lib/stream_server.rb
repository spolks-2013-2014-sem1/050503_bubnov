module Network
  class StreamServer
    def initialize(port)
      @socket = StreamSocket.new(port: port, host: '')
      @socket.bind
      @socket.listen
    end

    def self.listen(addrinfo, &block)
      socket = StreamServer.new(addrinfo[:port])
      yield socket
    ensure
      socket.close if socket
    end

    def select(timeout=Constants::TIMEOUT)
      @socket.select(timeout)
    end

    def accept
      @socket.accept
    end

    def close
      @socket.close
    end
  end
end