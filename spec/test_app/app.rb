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
loader.push_dir("#{File.dirname(__FILE__)}/app")
loader.push_dir("#{File.dirname(__FILE__)}/app/models") # make models a root namespace so we don't infer a `Models::` module
loader.push_dir("#{File.dirname(__FILE__)}/app/services") # make services a root namespace so we don't infer a `Services::` module
loader.setup

# Fifth: load configs
Dir[File.join(__dir__, "config", "*.rb")].each { require(_1) }

class TestApp < Kirei::App
  # Kirei configuration
  config.app_name = "test_app"
end

loader.eager_load
