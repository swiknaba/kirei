# typed: strict
# frozen_string_literal: true

module Kirei
  module Routing
    class Verb < T::Enum
      enums do
        # idempotent
        GET     = new("GET")

        # non-idempotent
        POST    = new("POST")

        # idempotent
        PUT     = new("PUT")

        # non-idempotent
        PATCH   = new("PATCH")

        # non-idempotent
        DELETE  = new("DELETE")

        # idempotent
        HEAD    = new("HEAD")

        # idempotent
        OPTIONS = new("OPTIONS")

        # idempotent
        TRACE   = new("TRACE")

        # non-idempotent
        CONNECT = new("CONNECT")
      end
    end
  end
end
