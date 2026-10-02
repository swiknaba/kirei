# typed: strict

module Dummy
  class RaisingController < Kirei::Controller
    sig { returns(T.anything) }
    def blow_up
      raise "boom"
    end
  end
end
