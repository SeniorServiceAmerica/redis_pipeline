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

Populate the configuration file with the redis uri and batch size.

* uri defaults to `redis://localhost:6379` if you don't have a configuration file
* batch size defaults to 1000 if you don't have a configuration file

## Usage

Create a new pipeline 

```ruby
 pipeline =  RedisPipeline::RedisPineline.new('redis_uri')
```

Queue up commands with add_commands either as a single string 

```ruby
 pipeline.commands.add('set hello world')
```

or an array

```ruby
	array = ['hset gem first_name redis', 'hset gem last_name pipeline']
	pipeline.commands.add(array)
```

The `<<` syntax works as well

```ruby
  pipeline.commands << 'set hello world'
  pipeline.commands << ['hset gem first_name redis', 'hset gem last_name pipeline']
```

Send them with execute(). Commands are sent using redis-rb's pipelined mode in batches, the size of which are controlled by your configuration. Returns false if there is an error

```ruby
  pipeline.execute()
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
