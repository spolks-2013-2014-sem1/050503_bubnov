require 'socket'

class LocalServer
  include Socket::Constants

  def initialize(port)
    @socket = Socket.new(AF_INET, SOCK_STREAM, 0)

    sockaddr = Socket.sockaddr_in(port, '127.0.0.1')
    @socket.bind(sockaddr)
    @socket.listen(1)
  end

  def accept
    @income_socket, = @socket.accept

    loop do
      data = @income_socket.readline
      @income_socket.write(data)
    end

  rescue EOFError
  ensure
    @income_socket.close if @income_socket
  end

  def close
    @socket.close unless @socket.closed?
    @income_socket.close if @income_socket and !@income_socket.closed?
  end

  def closed?
    @socket.closed? && @income_socket.closed?
  end

end