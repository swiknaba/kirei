# typed: false

require "fileutils"

module Cli
  module Commands
    module NewApp
      class Execute
        def self.call(app_name:)
          BaseDirectories.call
          Files::App.call(app_name)
          Files::Irbrc.call

          Kirei::Logger.logger.info(
            "Kirei app '#{app_name}' scaffolded successfully!",
          )
        end
      end
    end
  end
end
