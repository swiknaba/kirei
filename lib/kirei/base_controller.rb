# typed: strict
# frozen_string_literal: true

module Kirei
  class BaseController < Sinatra::Base
    extend T::Sig
    register(Sinatra::Namespace)

    before do
      Thread.current[:request_id] = request.env["HTTP_X_REQUEST_ID"].presence || "req_#{Kirei.env}_#{SecureRandom.uuid}"
    end
  end
end
