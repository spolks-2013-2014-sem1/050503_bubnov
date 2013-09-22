require 'socket'

class LocalServer
  include Socket::Constants

  def initialize(port)
    @socket = Socket.new(AF_INET, SOCK_STREAM, 0)

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

end