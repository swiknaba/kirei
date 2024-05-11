# typed: true

module Cli
  module Commands
    module NewApp
      module Files
        class SorbetConfig
          def self.call
            File.write("sorbet/config", content)
          end

          def self.content
            <<~TXT
              --dir
              .
              --ignore=vendor/
              --ignore=spec/

            TXT
          end
        end
      end
    end
  end
end
