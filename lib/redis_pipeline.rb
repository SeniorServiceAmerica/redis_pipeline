require_relative 'redis_pipeline/version'
require 'redis'
require 'active_support/inflector'
require 'gem_configurator'
require_relative 'redis_pipeline/redis_pipeline'
require_relative 'redis_pipeline/commands'
require_relative 'redis_pipeline/errors'

require 'bundler'
Bundler.require