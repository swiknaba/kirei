# typed: strict
# frozen_string_literal: true

module Controllers
  class Health < Base
    sig { returns(T.anything) }
    def livez
      TestApp.config.logger.info("Health check")
      TestApp.config.logger.info(params.inspect)
      render(TestApp.version, status: 200)
    end
  end
end
