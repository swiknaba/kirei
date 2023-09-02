# typed: false

RSpec.describe Kirei do
  it "has a version number following SemVer", :aggregate_failures do
    expect(Kirei::VERSION).not_to be_nil
    expect(Kirei::VERSION.match?(/^\d{1,}\.\d{1,}\.\d{1,}$/)).to be(true)
  end
end
