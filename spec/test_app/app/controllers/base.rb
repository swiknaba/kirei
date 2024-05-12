# typed: strict
# frozen_string_literal: true

module Controllers
  class Base < Kirei::Controller
    extend T::Sig

    before do
      puts "running before filter from Base"
    end

    after do
      puts "running AFTER filter from Base"
    end
  end
end
