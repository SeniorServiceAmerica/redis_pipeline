module RedisPipeline
  class Commands < Array

    # Alias for commands.add
    def <<(new_commands)
      self.add(new_commands)
    end

    # Adds commands to the collection. If passed an array, concatenates the passed array with the existing array of commands.
    #  commands.add('set hello world')
    #  commands.add(['hset gem first_name redis', 'hset gem last_name pipeline'])
    def add(new_commands)
      new_commands = [new_commands] if new_commands.class == String
      self.concat(new_commands)
    end
        
    # Sends [batch_size] commands to the passed redis instance.
    def execute_batch(redis, batch_size)
      redis.pipelined do
        batch(batch_size).each do |command|
          redis_args = command.split(" ")
          redis.send(*redis_args)
        end
      end
    end    
    
    private
    
    def batch(batch_size)
      command_batch = []
      self.first(batch_size).count.times do 
        command_batch << self.shift
      end
      command_batch
    end
    
  end
end