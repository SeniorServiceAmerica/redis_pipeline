module RedisPipeline
  class RedisPipeline
    include GemConfigurator
    
    require 'uri'
    require 'redis'

    attr_reader :errors, :commands

    # Instantiates and configures a redis pipeline.
    def initialize()
      configure
      self.redis = open_redis_connection
      self.commands = Commands.new
      self.errors = Errors.new
    end
    
    # Sends each command to the redis pipline, where it is processed.
    # Commands are removed from the command collection when sent to the pipeline.
    # Returns <tt>true</tt> if all commands succeed. Returns <tt>false</tt> if any command fails.
    def execute
      begin
        while commands.length > 0
          pipeline_commands(command_batch)
        end
      rescue => error
        errors << error.message
      end
      
      errors.empty?
    end

    private
      
      attr_writer :errors, :commands
      attr_accessor :redis
      
      def command_batch
        command_batch = []
        commands.first(@settings[:batch_size]).count.times do 
          command_batch << commands.shift
        end
        command_batch
      end
      
      def default_settings
        {:uri => 'redis://localhost:6379', :batch_size => 1000}
      end

      def open_redis_connection
        uri = URI.parse(settings[:uri])
        Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
      end
      
      def pipeline_commands(command_batch)
        redis.pipelined do 
          command_batch.each do |command|
            redis_args = command.split("|")
            redis.send(*redis_args)
          end
        end
      end
      
  end
end