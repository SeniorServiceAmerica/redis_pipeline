module RedisPipeline
  class RedisPipeline
    require 'uri'
    require 'redis'
        
    attr_reader :settings
    
    DEFAULT_SETTINGS = {:uri => 'redis://localhost:6379', :batch_size => 1000}
    
    def initialize()
      configure
      @redis = open_redis_connection
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
        @commands.first(@settings[:batch_size]).count.times do 
          command_batch << @commands.shift
        end
        command_batch
      end
    
      def config_path
        if defined?(Rails) && File.exists?(Rails.root.join("config","pipeline_config.yml"))
          Rails.root.join("config","pipeline_config.yml")
        else
          nil
        end
      end
      
      def configure
        raw_settings = parse_yaml(config_path())

        if raw_settings
          @settings = raw_settings[Rails.env]
        else
          @settings = {}          
        end
        
        @settings = DEFAULT_SETTINGS.merge(@settings)
      end
      
      def open_redis_connection
        uri = URI.parse(settings[:uri])
        Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
      end
      
      def parse_yaml(path)
        path ? YAML.load_file(path) : nil
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