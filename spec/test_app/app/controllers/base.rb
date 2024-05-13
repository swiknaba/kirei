# typed: strict
# frozen_string_literal: true

module Controllers
  class Base < Kirei::Controller
    extend T::Sig

    before do
      puts "filter running BEFORE any action in any controller"
    end

    after do
      puts "filter running AFTER any action in any controller"
    end
  end
end
