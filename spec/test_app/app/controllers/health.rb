# typed: strict
# frozen_string_literal: true

module Controllers
  class Health < Base
    sig { returns(T.anything) }
    def livez
      TestApp.config.logger.info("Health check")
      TestApp.config.logger.info(params.inspect)

      info = {
        "version" => TestApp.version,
        "req_host" => req_host,
        "req_domain" => req_domain,
        "req_subdomain" => req_subdomain,
        "req_port" => req_port,
        "req_ssl" => req_ssl?,
      }

      render(Oj.dump(info), status: 200)
    end
  end
end
