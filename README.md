# RedisPipeline

Creates a connection and a queue for pipelining commands to a redis server. Intended for mass inserting of data. 

## Installation

Add this line to your application's Gemfile:

    gem 'redis_pipeline'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install redis_pipeline

## Usage

Create a new pipeline 

```sh
 pipeline =  RedisPipeline::RedisPineline.new('redis_uri')
```

Add commands to it either as a single string 

```sh
 pipeline.add_commands('set hello world')
```

or an array

```sh
	array = ['hset person first_name jane', 'hset person last_name doe']
```

Send them with execute_command. Commands are sent using redis-rb's pipelined mode in batches of 1000. Returns false if there is an error

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
