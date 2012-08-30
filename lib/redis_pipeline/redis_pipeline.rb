module RedisPipeline
  class RedisPipeline
    include GemConfigurator
    
    require 'uri'
    require 'redis'

    attr_reader :errors

    def initialize()
      configure
      @redis = open_redis_connection
      @commands = []
      @errors = []
    end
    
    def add_commands(new_commands)
      new_commands = [new_commands] if new_commands.class == String
      @commands.concat(new_commands)
    end
    
    def execute_commands
      response = true
      begin
        while @commands.length > 0
          pipeline_commands(command_batch)
        end
      rescue => error
        @errors << error.message
        response = false
      end
      response
    end
    
    private
      
      attr_accessor :commands, :redis
      
      def command_batch
        command_batch = []
        @commands.first(@settings[:batch_size]).count.times do 
          command_batch << @commands.shift
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
        @redis.pipelined do 
          command_batch.each do |command|
            redis_args = command.split(" ")
            @redis.send(*redis_args)
          end
        end
      end
      
  end
end