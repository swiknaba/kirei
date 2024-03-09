# typed: false

module Cli
  module Commands
    module NewApp
      module Files
        class Routes
          def self.call
            File.write("config/routes.rb", content)
          end

          def self.content
            <<~RUBY
              # typed: strict
              # frozen_string_literal: true

              Kirei::Router.add_routes([
                # Kirei::Router::Route.new(
                #   method: "GET",
                #   path: "/livez",
                #   controller: Controllers::HealthController,
                #   action: "livez",
                # )
              ])
            RUBY
          end
        end
      end
    end
  end
end
