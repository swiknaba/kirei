# typed: strict

module Dummy
  class HealthController < Kirei::Controller
    sig { returns(T.anything) }
    def livez
      render(Oj.dump({ "ok" => true }))
    end
  end
end
