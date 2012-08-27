module RedisPipeline
  class RedisPipeline
    include GemConfigurator
  
    require 'uri'
    require 'redis'

    # Returns a new pipeline using the configuration provided, or the default settings if no configuration file available.
    def initialize()
      configure
    end
    
    def commands
      @commands ||= Commands.new
    end
        
    # Processess each command. Returns true if all all commands are successful. Returns false if any command fails.
    def execute
      response = true
      begin
        while commands.count > 0
          commands.execute_batch(redis, settings[:batch_size])
        end
      rescue 
        response = false
      end
      response
    end
    
    private

    def default_settings
      {:uri => 'redis://localhost:6379', :batch_size => 1000}
    end

    def open_redis_connection
      uri = URI.parse(settings[:uri])      
    end    
    
    def redis
      uri = URI.parse(settings[:uri])
      @redis ||= Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
    end
  end
end