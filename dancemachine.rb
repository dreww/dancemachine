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

    def say(*text)
      command "PRIVMSG", "##{ config.channel }", "#{text.flatten.join(' ')}"
    end

    def connection_completed
      puts "sending data"
      command "USER", [config.nick]*4
      command "NICK", "#{config.nick}"
      command "JOIN", "##{ config.channel }"
    end

    def receive_line(line)
       puts line
       command('PONG', $1) if line =~ /^PING (.*)/
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
      EM::run do
        bot = DanceMachine::IRC.connect(options)
        EM.add_timer(15) do
          bot.say("honk")
        end
      end
    end
  end
end

