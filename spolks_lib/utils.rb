require 'optparse'

module Utils
  class Handle
    def assign(*int, &block)
      int.each do |i|
        Signal.trap(i, block)
      end
    end
  end

  class ArgumentParser
    def initialize
      @options = {}

      @optparse = OptionParser.new do |opts|
        opts.banner = 'Usage: main.rb [options] [ip] [filepath]'

        @options[:listen] = false
        opts.on('-l', 'Listen port') do
          @options[:listen] = true
        end

        @options[:type] = :tcp
        opts.on('-u', 'Use UDP') do
          @options[:type] = :udp
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

        @options[:filepath] = nil
        opts.on(/.+/) do |filepath|
          @options[:filepath] = filepath
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

    def client?
      !@options[:listen] && @options[:ip] && @options[:port]
    end

    def server?
      @options[:listen] && @options[:port]
    end

    def file_client?
      client? && @options[:filepath]
    end

    def file_server?
      server? && @options[:filepath]
    end
  end

  class Pendulum
    def initialize(bound, step = 1)
      @ticker = 0
      @bound = bound
      @step = step
    end

    def dump?
      if @ticker == @bound
        @ticker = 0
        true
      else
        @ticker += @step
        false
      end
    end
  end
end