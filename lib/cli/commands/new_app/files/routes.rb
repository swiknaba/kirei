# typed: true

module Cli
  module Commands
    module NewApp
      module Files
        class Routes
          def self.call(_app_name)
            File.write("config/routes.rb", router)
            File.write("app/controllers/base.rb", base_controller)
          end

          def self.router
            <<~RUBY
              # typed: strict
              # frozen_string_literal: true

              module Kirei::Routing
                Router.add_health_routes!
              end
            RUBY
          end

          def self.base_controller
            <<~RUBY
              # typed: strict
              # frozen_string_literal: true

              module Controllers
                class Base < Kirei::Controller
                  extend T::Sig
                end
              end
            RUBY
          end
        end
      end
    end
  end
end
