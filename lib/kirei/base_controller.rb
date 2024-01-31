# typed: strict
# frozen_string_literal: true

require_relative("app")

module Kirei
  class BaseController < Kirei::App
    extend T::Sig
    # register(Sinatra::Namespace)

    # before do
    #   Thread.current[:request_id] = request.env["HTTP_X_REQUEST_ID"].presence ||
    #                                 "req_#{AppBase.environment}_#{SecureRandom.uuid}"
    # end
  end
end
