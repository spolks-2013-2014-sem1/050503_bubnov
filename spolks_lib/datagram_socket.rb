require 'socket'
require 'bindata'

module Network
  class Packet < BinData::Record
    endian :little
    uint32 :chunks
    uint32 :len
    uint32 :seek
    string :data, :read_length => :len
  end

  class DatagramSocket
    def initialize(sock_or_addr={})
      if sock_or_addr.instance_of?(Socket)
        @socket = sock_or_addr
      else
        @socket = Socket.new(Constants::AF_INET, Constants::SOCK_DGRAM, 0)
        @socket.setsockopt(Constants::SOL_SOCKET, Constants::SO_REUSEADDR, true)
        @sockaddr = Socket.sockaddr_in(sock_or_addr[:port], sock_or_addr[:host])
      end
    end

    def self.open(addrinfo, &block)
      socket = DatagramSocket.new(addrinfo)
      socket.connect
      yield socket
    ensure
      socket.close if socket
    end

    def self.listen(addrinfo, &block)
      socket = DatagramSocket.new(port: addrinfo[:port], host: '')
      socket.bind
      yield socket
    ensure
      socket.close if socket
    end

    def bind
      @socket.bind(@sockaddr)
    end

    def connect
      @socket.connect(@sockaddr)
    end

    def send(string, who=nil)
      if who
        @socket.send(string, 0, who)
      else
        @socket.send(string, 0)
      end
    end

    def recv(size=Constants::CHUNK_SIZE)
      @socket.recvfrom(size)
    end

    def select(descr={}, timeout=Constants::TIMEOUT)
      read_array = descr[:rs] ? [@socket] : []
      write_array = descr[:ws] ? [@socket] : []
      error_array = descr[:es] ? [@socket] : []

      rs, ws, es = IO.select(read_array, write_array, error_array, timeout)
      [rs ? rs.any? : false,
       rs ? ws.any? : false,
       es ? es.any? : false]
    end

    def close
      @socket.close
    end
  end
end
