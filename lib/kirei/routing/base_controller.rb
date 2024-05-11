# typed: strict
# frozen_string_literal: true

require_relative("base")

module Kirei
  module Routing
    class BaseController < Routing::Base
      extend T::Sig
      # register(Sinatra::Namespace)

      # before do
      #   Thread.current[:request_id] = request.env["HTTP_X_REQUEST_ID"].presence ||
      #                                 "req_#{App.environment}_#{SecureRandom.uuid}"
      # end
    end
  end
end
