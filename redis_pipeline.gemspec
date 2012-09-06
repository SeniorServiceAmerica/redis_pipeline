# -*- encoding: utf-8 -*-
require File.expand_path('../lib/redis_pipeline/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Ian Whitney", "Davin Lagerroos"]
  gem.email         = ["iwhitney@ssa-i.org", "dlagerroos@ssa-i.org"]
  gem.description   = %q{Send commands to a redis server in pipelined batches}
  gem.summary       = %q{Establishes a connection to a redis server. You can then pass it commands that will be queued to be pipelined. Intended for mass upload.}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "redis_pipeline"
  gem.require_paths = ["lib"]
  gem.version       = RedisPipeline::VERSION
  gem.add_dependency('gem_configurator', '~> 1.2')
  gem.add_dependency              'redis' 
  gem.add_development_dependency  'rake'  
end
