require "spec_helper"

# We never really enable the patch in this spec, just expecting on the
# return value. It's hard to more than this, because the patch is enabled
# in an initializer which is for dev only. Once modules have been mixed in,
# it's very hard to remove them, and we do not want any of them in tests.

describe DevMonkeyPatches do
  before { allow($stdout).to receive :puts } # Suppress standard output.
  before { allow(described_class).to receive(:enable!).and_return :stubbed }

  context "when in production" do
    before { allow(Rails.env).to receive(:production?).and_return true }

    it "it cannot be extended" do
      expect { described_class.enable }.to raise_error /cannot/
    end
  end

  context "when in development" do
    before { allow(Rails.env).to receive(:test?).and_return false }

    it "can be enabled" do
      expect(described_class.enable).to be :stubbed
    end

    it "can be suppressed with `NO_DEV_MONKEY_PATCHES=true`" do
      expect(ENV).to receive(:[]).with("NO_DEV_MONKEY_PATCHES").and_return "yes"
      expect(described_class.enable).to be nil
    end
  end

  context "when in test" do
    it "it's not enabled by default" do
      expect { described_class.enable }.to raise_error /in test/
    end
  end

  context "when in this spec" do
    it "didn't define anything on `Object`" do
      expect(respond_to?(:dev_dev_mixed_in?)).to be false
    end
  end
end
