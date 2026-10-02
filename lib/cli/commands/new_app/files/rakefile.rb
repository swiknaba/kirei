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

              kirei_gem_path = Gem::Specification.find_by_name("kirei").gem_dir
              Dir.glob("\#{kirei_gem_path}/lib/tasks/**/*.rake").each { import(_1) }

              Dir.glob("lib/tasks/**/*.rake").each { import(_1) }

            RUBY
          end
        end
      end
    end
  end
end
