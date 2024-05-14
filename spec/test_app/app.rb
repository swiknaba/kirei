# typed: true
# frozen_string_literal: true

# First: check if all gems are installed correctly
require "bundler/setup" # rubocop:disable Packaging/BundlerSetupInTests

# Second: load all gems
#         we have runtime/production ("default") and development gems ("development")
Bundler.require(:default)
Bundler.require(:development) if ENV["RACK_ENV"] == "development"
Bundler.require(:test) if ENV["RACK_ENV"] == "test"

# Third: load all initializers
Dir[File.join(__dir__, "config/initializers", "*.rb")].each { require(_1) }

# Fourth: load all application code
loader = Zeitwerk::Loader.new
loader.tag = File.basename(__FILE__, ".rb")
[
  "/app",
  "/app/models",
  "/app/services",
].each do |root_namespace|
  # a root namespace skips the auto-infered module for this folder
  # so we don't have to write e.g. `Models::` or `Services::`
  loader.push_dir("#{File.dirname(__FILE__)}#{root_namespace}")
end
loader.setup

# Fifth: load configs
Dir[File.join(__dir__, "config", "*.rb")].each { require(_1) }

# Last: configure the Kirei App
class TestApp < Kirei::App
  config.app_name = "test_app"

  # Logging
  config.log_level = Kirei::Logging::Level::INFO
  config.log_default_metadata = {
    "some_feature_flag_enabled" => "true",
  }
  config.metric_default_tags = {
    "some_feature_flag_enabled" => "true",
  }
end

loader.eager_load
