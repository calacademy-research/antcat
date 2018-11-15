require "spec_helper"

describe Feed, :feed do
  describe "enabling and disabling tracking" do
    it "is enabled by default" do
      expect(described_class.enabled?).to be true
    end

    it "can be disabled and enabled" do
      described_class.enabled = false
      expect { described_class.enabled = true }.
        to change { described_class.enabled? }.from(false).to(true)
    end
  end
end
