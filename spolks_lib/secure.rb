module Secure
  def self.safe
    yield
  rescue => e
    IO.console.puts(e)

  end

  class Handle
    def assign(*int, &block)
      int.each do |i|
        Signal.trap(i, block)
      end
    end
  end
end