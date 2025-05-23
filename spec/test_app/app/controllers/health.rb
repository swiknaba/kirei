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
        "req_host" => request.host,
        "req_domain" => request.domain,
        "req_subdomain" => request.subdomain,
        "req_port" => request.port,
        "req_ssl" => request.ssl?,
      }

      render(Oj.dump(info), status: 200)
    end
  end
end
