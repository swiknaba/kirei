# typed: true

module Kirei
  module Domain
    module Entity
      include Kernel

      sig { returns(T.any(String, Integer)) }
      def id; end
    end

    module ValueObject
      include Kernel
    end
  end
end
