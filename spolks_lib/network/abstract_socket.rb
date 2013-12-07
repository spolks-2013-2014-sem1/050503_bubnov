module Network
  class AbstractSocket
    def self.select(rs=nil, ws=nil, es=nil, timeout=Constants::TIMEOUT)
      ra = rs ? rs.map(&:fd) : rs
      wa = ws ? ws.map(&:fd) : ws
      ea = es ? es.map(&:fd) : es

      ra, wa, ea = IO.select(ra, wa, ea, timeout)

      read = ra ? [] : nil
      write = wa ? [] : nil
      error = ea ? [] : nil

      rs.each do |s|
        read << s if ra.include? s.fd
      end if ra and ra.any?

      ws.each do |s|
        write << s if wa.include? s.fd
      end if wa and wa.any?

      es.each do |s|
        error << s if ea.include? s.fd
      end if ea and ea.any?

      [read, write, error]
    end
  end
end