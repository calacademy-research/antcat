require 'rails_helper'

# We never really enable the patch in this spec beause it's very hard
# to remove modules have been mixed in.

describe DevMonkeyPatches do
  context "when in production" do
    before { allow(Rails.env).to receive(:production?).and_return true }

    it "cannot be enabled" do
      expect { described_class.enable }.to raise_error("`DevMonkeyPatches` cannot be enabled in production")
    end
  end

  context "when in test" do
    it "it's not enabled by default" do
      expect { described_class.enable }.to raise_error("use `DevMonkeyPatches.enable!` in test")
    end
  end

  context "when in this spec" do
    it "didn't define anything on `Object`" do
      expect(respond_to?(:dev_dev_mixed_in?)).to be false
    end
  end
end
