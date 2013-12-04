require 'socket'
require 'bindata'

module Network
  include Socket::Constants

  ACK = 'ACK'
  FIN = 'FIN'
  CHUNK_SIZE = 32768
  TIMEOUT = 10

  class Packet < BinData::Record
    endian :little
    uint32 :chunks
    uint32 :len
    uint32 :seek
    string :data, :read_length => :len
  end

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
    end
  end
end