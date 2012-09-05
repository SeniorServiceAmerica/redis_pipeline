require 'test_helper'

class TestRedisPipeline < Test::Unit::TestCase

  def setup 
    @pipeline = RedisPipeline::RedisPipeline.new
    @uri = @pipeline.settings[:uri]
  end
  
  def teardown 
    uri_parsed = URI.parse(@uri)
    redis = Redis.new(:host => uri_parsed.host, :port => uri_parsed.port, :password => uri_parsed.password)
    redis.flushall
  end

  def test_pipeline_establishes_connection_to_redis_server
    assert_not_nil @pipeline
  end
  
  def test_pipeline_has_empty_command_list
    assert_equal 0, @pipeline.send(:commands).length
  end
  
  def test_add_commands_adds_array_of_commands_as_seperate_commands
    commands = ["hset|person:0|first_name|joe", "hest|person:0|last_name|smith"]
    @pipeline.commands.add(commands)
    assert_equal commands.length, @pipeline.send(:commands).length
  end
  
  def test_add_commands_adds_string_as_single_command
    commands = "hset|person:0 first_name joe"
    @pipeline.commands.add(commands)
    assert_equal 1, @pipeline.send(:commands).length
  end
  
  def test_add_commands_queues_commands_at_end
    commands = ["hset|person:0|first_name|joe", "hest|person:0|last_name|smith"]
    @pipeline.commands.add(commands)
    last_command = "hset|person:1|first_name|jane"
    @pipeline.commands.add(last_command)
    assert_equal commands[0], @pipeline.send(:commands).first
    assert_equal last_command, @pipeline.send(:commands).last
  end
  
  def test_command_batch_returns_batch_size_number_of_items
    full_command_set = three_batches_of_commands
    @pipeline.commands.add(full_command_set)
    single_batch = @pipeline.send(:command_batch)
    
    upper_limit = (@pipeline.settings[:batch_size] - 1)
    assert_equal full_command_set[0..upper_limit], single_batch 
  end
  
  def test_command_batch_takes_batch_size_items_out_of_commands
    @pipeline.commands.add(three_batches_of_commands)
    count = @pipeline.send(:commands).length
    @pipeline.send(:command_batch)
    assert_equal (count - @pipeline.settings[:batch_size]), @pipeline.send(:commands).length
  end
  
  def test_execute_sends_commands_to_redis
    uri_parsed = URI.parse(@uri)
    redis = Redis.new(:host => uri_parsed.host, :port => uri_parsed.port, :password => uri_parsed.password)    
    @pipeline.commands.add(three_batches_of_commands)
    
    first_command = @pipeline.send(:commands).first.split("|")
    last_command = @pipeline.send(:commands).last.split("|")
    assert_equal Hash.new(), redis.send("hgetall", first_command[1])
    assert_equal Hash.new(), redis.send("hgetall", last_command[1])
    
    @pipeline.execute
    assert_equal first_command.last, redis.send("hget", *first_command[1..-2])
    assert_equal last_command.last, redis.send("hget", *last_command[1..-2])
  end
  
  def test_after_execute_no_items_in_command
    @pipeline.commands.add(three_batches_of_commands)
    @pipeline.execute
    assert_equal 0, @pipeline.send(:commands).length
  end
  
  def test_execute_commands_returns_true_if_successful
    @pipeline.commands.add(three_batches_of_commands)
    assert @pipeline.execute
  end
  
  def test_execute_commands_returns_false_if_error
    mismatched_commands = ['set|"string_key"|"string_value"', 'hget|"string_key"|"string_not_a_hash"']
    @pipeline.commands.add(mismatched_commands)
    assert_equal false, @pipeline.execute
  end
  
  def test_execute_commands_populates_errors_if_error
    mismatched_commands = ['set|"string_key"|"string_value"', 'hget|"string_key"|"string_not_a_hash"']
    @pipeline.commands.add(mismatched_commands)
    @pipeline.execute
    assert_equal 1, @pipeline.errors.count, "#{@pipeline.errors.inspect}"
    assert_equal 'ERR Operation against a key holding the wrong kind of value', @pipeline.errors[0]
  end
  
  private

    def three_batches_of_commands
      first_names = ["Lindsey Sue", "Dodie", "Tommie", "Aletha", "Matilda", "Robby", "Forest", "Sherrie", "Elroy", "Darlene", "Blossom", "Preston", "Ivan", "Denisha", "Antonietta", "Lenora", "Fatimah", "Alvaro", "Madeleine", "Johnsie", "Jacki"]
      last_names = ["Austino", "Egnor", "Mclauglin", "Vettel", "Osornio", "Kloke", "Neall", "Licon", "Bergren", "Guialdo", "Heu", "Lilla", "Fogt", "Ellinghuysen", "Banner", "Gammage", "Fleniken", "Byerley", "Mccandless", "Hatchet", "Segal", "Bagnall", "Mangum", "Marinella", "Hunke", "Klis", "Skonczewski", "Aiava", "Masson", "Hochhauser", "Pfost", "Cripps", "Surrell", "Carstens", "Moeder", "Feller", "Turri", "Plummer", "Liuzza", "Macaskill", "Pirie", "Haase", "Gummersheimer", "Caden", "Balich", "Franssen", "Barbur", "Bonker", "Millar", "Armijo", "Canales", "Kucera", "Ahlstrom", "Marcoux", "Dagel", "Vandonsel", "Lagrasse", "Bolten", "Smyer", "Spiker", "Detz", "Munar", "Oieda", "Westin", "Levenson", "Ramagos", "Lipson", "Crankshaw", "Polton", "Seibt", "Genrich", "Shempert", "Bonillas", "Stout", "Caselli", "Jaji", "Kudo", "Feauto", "Hetland", "Hsieh", "Iwasko", "Jayme", "Lebby", "Dircks", "Hainley", "Gielstra", "Dozois", "Suss", "Matern", "Mcloud", "Fassio", "Blumstein", "Qin", "Gindi", "Petrizzo", "Beath", "Tonneson", "Fraga", "Tamura", "Cappellano", "Galella"]

      # each first_name,last_name pair is 2 commands so to get 2 batches plus extra we only need batch_size number pairs plus some extra * 1.33
      number_of_commands = (@pipeline.settings[:batch_size]  * 1.33)
      commands = []
      (0..number_of_commands).each do |i|
        first = first_names.shift
        last = last_names.shift        
        commands << "hset|person:#{i}|first_name|#{first}"
        commands << "hset|person:#{i}|lsst_name|#{last}" 
        first_names.push(first)
        last_names.push(last)
      end
      commands 
    end
  
end