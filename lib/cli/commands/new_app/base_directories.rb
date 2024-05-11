# typed: true

module Cli
  module Commands
    module NewApp
      class BaseDirectories
        def self.call
          directories.each do |dir|
            FileUtils.mkdir_p(dir)
          end
        end

        def self.directories
          [
            "app",
            "app/controllers",
            "app/models",
            "app/services",

            "bin",
            "config",
            "config/initializers",

            "db",
            "db/migrate",
            "db/seeds",

            "lib",
            "lib/tasks",

            "sorbet",
            "sorbet/rbi",
            "sorbet/rbi/shims",
            "sorbet/tapioca",

            "spec",
            "spec/factories",
            "spec/fixtures",
            "spec/support",
          ]
        end
      end
    end
  end
end
