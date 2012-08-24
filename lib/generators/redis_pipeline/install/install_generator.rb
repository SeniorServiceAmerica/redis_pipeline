module RedisPipeline
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../templates", __FILE__)

      def copy_initializer_file
        copy_file "redis_pipeline.example.yml", "config/redis_pipeline.yml"
      end
    end
  end
end