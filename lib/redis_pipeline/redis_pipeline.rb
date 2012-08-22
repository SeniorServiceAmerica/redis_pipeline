module RedisPipeline
  class RedisPipeline
    require 'uri'
    require 'redis'
        
    attr_reader :settings
    
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
          @environment = Rails.env
        else
          nil
        end
      end
      
      def configure
        raw_settings = parse_yaml(config_path())
        if raw_settings
          @settings = {:uri => raw_settings[@environment]['uri'], :batch_size => raw_settings[@environment]['pipeline_batch_size']}
        else
          @settings = {:uri => 'redis://localhost:6379', :batch_size => 1000}
        end
      end
      
      def open_redis_connection
        uri = URI.parse(settings[:uri])
        Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
      end
      
      def parse_yaml(path)
        if path && File.exists?(path)
          YAML.load_file(path)
        else
          nil
        end
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