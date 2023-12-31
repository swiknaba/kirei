# typed: true

require "fileutils"

module Cli
  module Commands
    class Start
      def self.call(args)
        case args[0]
        when "new"
          app_name = args[1] || "MyApp"
          # @TODO(lud, 31.12.2023): classify is from ActiveSupport -> remove this?
          app_name = app_name.gsub(/[-\s]/, "_").classify
          NewApp::Execute.call(app_name: app_name)
        else
          Kirei::Logger.logger.info("Unknown command")
        end
      end
    end
  end
end
