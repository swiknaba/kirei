# typed: true

module Cli
  module Commands
    module NewApp
      module Files
        class Rakefile
          def self.call
            File.write("Rakefile", content)
          end

          def self.content
            <<~RUBY
              # typed: false
              # frozen_string_literal: true

              require "rake"
              require_relative "app"

              Dir.glob("#{Kirei::GEM_ROOT}/lib/tasks/**/*.rake").each { import(_1) }

              Dir.glob("lib/tasks/**/*.rake").each { import(_1) }

            RUBY
          end
        end
      end
    end
  end
end
