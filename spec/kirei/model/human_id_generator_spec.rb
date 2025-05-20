# typed: false

require "spec_helper"

RSpec.describe Kirei::Model::HumanIdGenerator do
  describe ".call" do
    it "generates an id with the prefix and desired length" do
      id = described_class.call(length: 8, prefix: "abc")

      expect(id).to start_with("abc_")
      expect(id.length).to eq(12)
    end
  end
end
