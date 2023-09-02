# typed: strict
# frozen_string_literal: true

puts "Booting Kirei..." # rubocop:disable all

require "boot"

module Kirei
  extend T::Sig

  ROOT_DIR = T.let(
    Gem::Specification.find_by_name("kirei").gem_dir,
    String,
  )

  sig { returns(Pathname) }
  def self.root
    Pathname.new(ROOT_DIR)
  end

  sig { returns(String) }
  def self.version
    @version = T.let(@version, T.nilable(String))
    @version ||= ENV.fetch("APP_VERSION", nil)
    @version ||= ENV.fetch("GIT_SHA", nil)
    @version ||= `git rev-parse --short HEAD`.to_s.chomp.freeze # localhost
  end

  sig { returns(String) }
  def self.env
    ENV.fetch("RACK_ENV", "development")
  end
end

puts "Kirei (#{Kirei::VERSION}) booted!" # rubocop:disable all
