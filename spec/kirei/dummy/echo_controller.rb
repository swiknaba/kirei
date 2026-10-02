# typed: strict

module Dummy
  class EchoController < Kirei::Controller
    sig { returns(T.anything) }
    def create
      render(Oj.dump(params))
    end
  end
end
