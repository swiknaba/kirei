# typed: false

module Cli
  module Commands
    module NewApp
      module Files
        class App
          def self.call(app_name)
            File.write("app.rb", content(app_name))
          end

          def self.content(app_name)
            <<~RUBY
              # typed: true
              # frozen_string_literal: true

              # First: check if all gems are installed correctly
              require 'bundler/setup'

              # Second: load all gems
              #         we have runtime/production ("default") and development gems ("development")
              Bundler.require(:default)
              Bundler.require(:development) if ENV['RACK_ENV'] == 'development'
              Bundler.require(:test) if ENV['RACK_ENV'] == 'test'

              # Third: load all initializers
              Dir[File.join(__dir__, 'config/initializers', '*.rb')].each { require(_1) }

              # Fourth: load all application code
              Dir[File.join(__dir__, 'app/**/*', '*.rb')].each { require(_1) }

              # Fifth: load configs
              Dir[File.join(__dir__, 'config', '*.rb')].each { require(_1) }

              class #{app_name} < Kirei::Base
              end
            RUBY
          end
        end
      end
    end
  end
end
