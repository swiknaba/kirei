# typed: false

module Cli
  module Commands
    module NewApp
      module Files
        class ConfigRu
          def self.call(app_name)
            File.write("config.ru", content(app_name))
          end

          def self.content(app_name)
            <<~RUBY
              # typed: false
              # frozen_string_literal: true

              require_relative("app")

              # Load middlewares here
              use(Rack::Reloader, 0) if #{app_name}.environment == "development"

              # Launch the app
              run(#{app_name}.new)

              # "use" all controllers
              # store all routes in a global variable to render (localhost only)
              # put "booted" statement
            RUBY
          end
        end
      end
    end
  end
end
