# typed: true
# frozen_string_literal: true

module Middleware
  class Example
    def initialize(app)
      @app = app
    end

    def call(env)
      puts("\nrunning custom middleware 'example'\n")

      #
      # do magic
      #

      @app.call(env)
    end
  end
end
