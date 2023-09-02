# typed: strict
# frozen_string_literal: true

require_relative "kirei"

Dir[File.join(__dir__, "lib/cli/**/*.rb")].each { require(_1) }

module Cli
end
