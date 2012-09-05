# RedisPipeline

Creates a connection and a queue for pipelining commands to a redis server. Uses redis-rb. Intended for mass inserting of data. 

## Installation

Add this line to your application's Gemfile:

    gem 'redis_pipeline'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install redis_pipeline

## Setup 

Create the configuration yaml file

    rails generate redis_pipeline

Populate the configuration file with the redis uri and batch size. The configuration file is stored at `config/redis_pipeline.yml`

* uri defaults to `redis://localhost:6379` if you don't have a configuration file
* batch size defaults to 1000 if you don't have a configuration file

## Usage

Create a new pipeline 

```ruby
 pipeline =  RedisPipeline::RedisPineline.new
```

Queue up commands by adding them. You can add a single command as a string. Within a command the | character is used to separate the parts of the command.

```ruby
 pipeline.add_command('set|hello|world')
```

Or pass an array of commands.

```ruby
	array = ['hset|gem|first_name|redis', '|hset|gem|last_name|pipeline']
	pipeline.add_command(array)
```

The shovel operator works as well.

```ruby
 pipeline << 'set|hello|world'
 pipeline << ['hset|gem|first_name|redis', '|hset|gem|last_name|pipeline']
```

Send the commands to redis with <tt>execute</tt>. Commands are sent using redis-rb's pipelined mode in batches, the size of which are controlled by your configuration. Returns false if there is an error, true if all commands succeed.

```ruby
  pipeline.execute
```

See the pipeline errors by iterating through `pipeline.errors`.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
