require "spec_helper"

describe Feed, feed: true do
  describe "globally enabling and disabling tracking" do
    it "is enabled by default" do
      expect(Feed.enabled?).to be true
    end

    it "can be disabled and enabled" do
      Feed.enabled = false
      expect(Feed.enabled?).to be false

      Feed.enabled = true
      expect(Feed.enabled?).to be true
    end
  end
end
