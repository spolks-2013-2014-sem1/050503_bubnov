require 'bindata'

module Network
  class Packet < BinData::Record
    endian :little
    uint32 :chunks
    uint32 :len
    uint32 :seek
    string :data, :read_length => :len
  end
end