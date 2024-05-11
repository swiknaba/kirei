# typed: true

module Cli
  module Commands
    module NewApp
      module Files
        class Routes
          def self.call(app_name)
            File.write("config/routes.rb", router)
            File.write("app/controllers/base.rb", base_controller)
            File.write("app/controllers/health.rb", health_controller(app_name))
          end

          def self.router
            <<~RUBY
              # typed: strict
              # frozen_string_literal: true

              include(Kirei::Routing)

              Router.add_routes(
                [
                  Router::Route.new(
                    verb: Router::Verb::GET,
                    path: "/livez",
                    controller: Controllers::Health,
                    action: "livez",
                  ),
                ],
              )
            RUBY
          end

          def self.base_controller
            <<~RUBY
              # typed: strict
              # frozen_string_literal: true

              module Controllers
                class Base < Kirei::Routing::BaseController
                  extend T::Sig
                end
              end
            RUBY
          end

          def self.health_controller(app_name)
            <<~RUBY
              # typed: strict
              # frozen_string_literal: true

              module Controllers
                class Health < Base
                  sig { returns(Kirei::Middleware::RackResponseType) }
                  def livez
                    #{app_name}.config.logger.info("Health check")
                    #{app_name}.config.logger.info(params.inspect)
                    render(#{app_name}.version, status: 200)
                  end
                end
              end
            RUBY
          end
        end
      end
    end
  end
end
