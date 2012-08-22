class RedisPipelineGenerator < Rails::Generators::Base
  source_root File.expand_path("../../templates", __FILE__)

  def copy_initializer_file
    copy_file "pipeline_config.example.yml", "config/pipeline_config.yml"
  end
end