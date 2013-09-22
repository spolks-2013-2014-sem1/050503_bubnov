require 'optparse'

class ArgumentParser
  def initialize
    @options = {}

    @optparse = OptionParser.new do |opts|
      opts.banner = 'Usage: netdup.rb [options] [ip] <port> < | > file'

      @options[:listen] = false
      opts.on('-l', 'Listen port') do
        @options[:listen] = true
      end

      @options[:verbose] = false
      opts.on('-v', 'Be verbose') do
        @options[:verbose] = true
      end

      opts.on(/^([0-9]{1,3}\.){3}[0-9]{1,3}$/) do |ip|
        @options[:ip] = ip
      end

      opts.on(/^[0-9]+$/) do |port|
        @options[:port] = port
      end

      opts.on('-h', '--help', 'Display this screen') do
        puts opts
        exit
      end
    end
  end

  def parse!
    @optparse.parse!
  end

  def help
    @optparse.help
  end

  def [](label)
    @options[label]
  end

end