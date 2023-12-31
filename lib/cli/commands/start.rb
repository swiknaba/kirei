# typed: false

require "fileutils"

module Cli
  module Commands
    class Start
      def self.call(args)
        case args[0]
        when "new"
          app_name = args[1] || "MyApp"
          app_name = app_name.gsub(/[-\s]/, "_").classify
          NewApp::Execute.call(app_name: app_name)
        else
          Kirei::Logger.logger.info("Unknown command")
        end
      end
    end
  end
end
