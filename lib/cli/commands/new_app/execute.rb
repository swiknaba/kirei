# typed: true

require "fileutils"

module Cli
  module Commands
    module NewApp
      class Execute
        def self.call(app_name:)
          BaseDirectories.call
          Files::App.call(app_name)
          Files::ConfigRu.call(app_name)
          Files::DbRake.call(app_name)
          Files::Irbrc.call
          Files::Rakefile.call
          Files::Routes.call(app_name)
          Files::SorbetConfig.call

          Kirei::Logging::Logger.logger.info(
            "Kirei app '#{app_name}' scaffolded successfully!",
          )
        end
      end
    end
  end
end
