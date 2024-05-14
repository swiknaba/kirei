# typed: strict
# frozen_string_literal: true

module Kirei
  module Logging
    class Level < T::Enum
      extend T::Sig

      enums do
        UNKNOWN = new(5) # An unknown message that should always be logged.
        FATAL   = new(4) # An unhandleable error that results in a program crash.
        ERROR   = new(3) # A handleable error condition.
        WARN    = new(2) # A warning.
        INFO    = new(1) # Generic (useful) information about system operation.
        DEBUG   = new(0) # Low-level information for developers.
      end

      sig { returns(String) }
      def to_human
        case self
        when UNKNOWN then "UNKNOWN"
        when FATAL   then "FATAL"
        when ERROR   then "ERROR"
        when WARN    then "WARN"
        when INFO    then "INFO"
        when DEBUG   then "DEBUG"
        else
          T.absurd(self)
        end
      end
    end
  end
end
