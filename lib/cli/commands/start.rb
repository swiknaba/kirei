# typed: false

require "fileutils"
require "active_support/all"

module Cli
  module Commands
    class Start
      def self.call(args)
        case args[0]
        when "new"
          app_name = args[1]&.classify || "MyApp"
          NewApp::Execute.call(app_name: app_name)
        else
          puts "Unknown command" # rubocop:disable all
        end
      end
    end
  end
end
