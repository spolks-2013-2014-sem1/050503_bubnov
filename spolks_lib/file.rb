module XIO
  module Constants
    CHUNK_SIZE = 32768
  end

  class XFile
    def initialize(filename, mode='w+')
      @file = File.open(filename, mode)
    end

    def self.read(what, &block)
      file = XFile.new(what[:file], 'r+')

      loop do
        string = file.read
        break unless string
        yield file, string
      end
    ensure
      file.close if file
    end

    def self.write(what, &block)
      file = XFile.new(what[:file])
      yield file
    ensure
      file.close if file
    end

    def chunks
      chunks = size / Constants::CHUNK_SIZE
      chunks += 1 unless size % Constants::CHUNK_SIZE == 0
      chunks
    end

    def seek(pos)
      @file.seek pos
    end

    def seek_chunk(number)
      @file.seek number * Constants::CHUNK_SIZE
    end

    def read
      @file.read Constants::CHUNK_SIZE
    end

    def write(string)
      @file.write string
    end

    def pos
      @file.pos
    end

    def size
      @file.size
    end

    def close
      @file.close
    end
  end
end