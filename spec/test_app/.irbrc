# frozen_string_literal: true

# Kirei needs to know where the root of the project is
APP_ROOT = File.expand_path(__dir__)

ENV["RACK_ENV"] ||= "development"
ENV["APP_VERSION"] ||= (ENV["GIT_SHA"] ||= `git rev-parse --short HEAD`.to_s.chomp.freeze)
require("dotenv/load") if %w[test development].include?(ENV["RACK_ENV"])
require_relative("app")
