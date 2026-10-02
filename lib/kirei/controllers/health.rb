# typed: strict
# frozen_string_literal: true

module Kirei
  module Controllers
    #
    # Built-in health check controller implementing Kubernetes API health endpoints.
    #
    # Provides three endpoints following the Kubernetes convention:
    #   - /livez   — Liveness probe. Indicates the process is alive.
    #   - /readyz  — Readiness probe. Verifies downstream dependencies (DB) are reachable.
    #   - /healthz — Deprecated alias for /livez (deprecated since Kubernetes v1.16).
    #
    # Reference: https://kubernetes.io/docs/reference/using-api/health-checks/
    #
    class Health < Kirei::Controller
      extend T::Sig

      sig { returns(Routing::RackResponseType) }
      def livez
        info = {
          "status" => "ok",
          "version" => App.version,
          "app_name" => App.config.app_name,
          "environment" => App.environment,
          "req_host" => request.host,
          "req_port" => request.port,
          "req_ssl" => request.ssl?,
        }

        Kirei::Logging::Logger.call(
          level: Kirei::Logging::Level::INFO,
          label: "Health check",
          meta: info,
        )

        render_json(info, status: 200)
      end
      alias healthz livez

      sig { returns(Routing::RackResponseType) }
      def readyz
        T.unsafe(App.raw_db_connection).execute("SELECT 1")

        Kirei::Logging::Logger.call(
          level: Kirei::Logging::Level::INFO,
          label: "Readiness check",
          meta: { "status" => "ok" },
        )

        render_json({ "status" => "ok" }, status: 200)
      rescue Sequel::Error => e
        Kirei::Logging::Logger.call(
          level: Kirei::Logging::Level::ERROR,
          label: "Readiness check failed",
          meta: { "error" => e.message },
        )

        render_json({ "status" => "unavailable", "reason" => e.message }, status: 503)
      end
    end
  end
end
