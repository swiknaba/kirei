# typed: strict
# frozen_string_literal: true

module Kirei
  module Routing
    class Request < T::Struct
      extend T::Sig

      const :env, T::Hash[String, T.untyped]

      sig { returns(String) }
      def host
        env.fetch("HTTP_HOST")
      end

      sig { returns(String) }
      def domain
        T.must(host.split(":").first).split(".").last(2).join(".")
      end

      sig { returns(T.nilable(String)) }
      def subdomain
        parts = T.must(host.split(":").first).split(".")
        return if parts.size <= 2

        T.must(parts[0..-3]).join(".")
      end

      sig { returns(Integer) }
      def port
        env.fetch("SERVER_PORT")&.to_i
      end

      sig { returns(T::Boolean) }
      def ssl?
        env.fetch("HTTPS", env.fetch("rack.url_scheme", "http")) == "https"
      end
    end
  end
end
