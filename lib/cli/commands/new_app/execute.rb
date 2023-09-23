# typed: false

require "fileutils"
require "active_support/all"

module Cli
  module Commands
    module NewApp
      class Execute
        def self.call(app_name:)
          BaseDirectories.call
          Files::App.call(app_name)
          Files::Irbrc.call

          puts "Kirei app '#{app_name}' scaffolded successfully!" # rubocop:disable all
        end
      end
    end
  end
end
