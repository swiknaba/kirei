# typed: true

module Cli
  module Commands
    module NewApp
      module Files
        class App
          def self.call(app_name)
            File.write("app.rb", content(app_name))
          end

          def self.content(app_name)
            snake_case_app_name = app_name.gsub(/([a-z])([A-Z])/, '\1_\2').downcase

            <<~RUBY
              # typed: true
              # frozen_string_literal: true

              # First: check if all gems are installed correctly
              require "bundler/setup"

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
                loader.push_dir("\#{File.dirname(__FILE__)}\#{root_namespace}")
              end
              loader.setup

              # Fifth: load configs
              Dir[File.join(__dir__, "config", "**", "*.rb")].each do |cnf|
                require(cnf) unless cnf.split("/").include?("initializers")
              end

              class #{app_name} < Kirei::App
                # Kirei configuration
                config.app_name = "#{snake_case_app_name}"
              end

              loader.eager_load
            RUBY
          end
        end
      end
    end
  end
end
