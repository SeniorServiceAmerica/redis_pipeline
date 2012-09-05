module RedisPipeline
  class Commands < Array
    
    # Adds commands to the piplined. Pass either a single command in a string or an array of commands
    #   pipeline.commands.add('set|hello|world') => [all_commands]
    #   pipeline.commands.add(['hset|gem|first_name|redis', '|hset|gem|last_name|pipeline']) => [all_commands]
    # Within a command the | character is used to separate the parts of the command.
    # Returns an array of all commands that have been added.
    #   commands are removed from the array when they are executed
    def add(new_commands)
      new_commands = [new_commands] if new_commands.class == String
      self.concat(new_commands)
    end    
  end
end
