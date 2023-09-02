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

              class #{app_name} < Kirei::Router
              end
            RUBY
          end
        end
      end
    end
  end
end
