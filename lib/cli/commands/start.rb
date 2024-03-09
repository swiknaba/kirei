# typed: true

require "fileutils"

module Cli
  module Commands
    class Start
      def self.call(args)
        case args[0]
        when "new"
          app_name = args[1] || "MyApp"
          app_name = app_name.gsub(/[-\s]/, "_")
          app_name = app_name.split('_').map(&:capitalize).join if app_name.include?('_')
          NewApp::Execute.call(app_name: app_name)
        else
          Kirei::Logger.logger.info("Unknown command")
        end
      end
    end
  end
end
