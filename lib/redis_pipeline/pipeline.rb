module RedisPipeline
  class RedisPipeline
    require 'uri'
    require 'redis'
    
    PIPELINE_BATCH_SIZE = 1000
    
    def initialize(redis_uri)
      @redis = open_redis_connection(redis_uri)
      @commands = []
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
      rescue 
        response = false
      end
      response
    end
    
    private
      
      attr_accessor :commands, :redis
      
      def command_batch
        command_batch = []
        @commands.first(PIPELINE_BATCH_SIZE).count.times do 
          command_batch << @commands.shift
        end
        command_batch
      end
      
      def open_redis_connection(redis_uri)
        uri = URI.parse(redis_uri)
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