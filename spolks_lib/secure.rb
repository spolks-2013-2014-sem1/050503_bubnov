module Secure
  class Handle
    def assign(*int, &block)
      int.each do |i|
        Signal.trap(i, block)
      end
    end
  end
end