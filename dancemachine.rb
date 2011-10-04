module DanceMachine
  class IRC < EM::Connection
    include EventMachine::Protocols::LineText2

    attr_accessor :config

    def initialize(options)
      self.config = OpenStruct.new(options)
    end
    
    def self.connect(options)
      connection = EM.connect(options[:server], options[:port].to_i, self, options)
    end

    def command(*cmd)
      puts "#{cmd.flatten.join(' ')}\r\n"
      send_data "#{ cmd.flatten.join(' ') }\r\n"
    end

    def post_init
      EM.add_timer(3) do
        puts "sending data"
        command "USER", [config.nick]*4
        command "NICK", "#{config.nick}"
        command "JOIN", "##{ config.channel }"
      end
    end

    def receive_line(line)
      case line
        when /^PING (.*)/ then command('PONG', $1)
        else puts line;
      end
    end

    def unbind
      EM.add_timer(10) do 
        reconnect(config.server, config.port.to_i)
        post_init
      end
    end
  end
  
  class Bot
    def self.go(options)
      EventMachine::run do
        DanceMachine::IRC.connect(options)
      end
    end
  end
end

