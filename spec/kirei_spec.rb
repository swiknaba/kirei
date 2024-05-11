# typed: false

RSpec.describe Kirei do
  let(:loader) { Zeitwerk::Loader.for_gem(warn_on_extra_files: false) }

  it "has a version number following SemVer", :aggregate_failures do
    expect(Kirei::VERSION).not_to be_nil
    expect(Kirei::VERSION.match?(/^\d{1,}\.\d{1,}\.\d{1,}$/)).to be(true)
  end

  it "loads all files and constants correctly" do
    expect do
      loader.setup
      loader.ignore(__dir__) # the specs are not auto-loadable
      loader.eager_load(force: true) # raises `Zeitwerk::NameError` if any constant is not loaded
    end.not_to raise_error
  end
end
