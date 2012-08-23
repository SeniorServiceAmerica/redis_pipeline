require_relative 'redis_pipeline/version'
require 'redis'
require 'active_support/inflector'
require_relative 'redis_pipeline/redis_pipeline'

require 'bundler'
Bundler.require
include GemConfigurator