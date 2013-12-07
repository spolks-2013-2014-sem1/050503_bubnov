require 'socket'

module Network
  module Constants
    include Socket::Constants

    ACK = 'ACK'
    FIN = 'FIN'
    CHUNK_SIZE = 32768
    PACKET_SIZE = CHUNK_SIZE + 12
    TIMEOUT = 10
  end
end
