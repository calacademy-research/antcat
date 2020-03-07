require 'rails_helper'

# We never really enable the patch in this spec because it's very hard
# to remove modules that have been mixed in.

describe DevMonkeyPatches do
  before do
    allow(described_class).to receive(:enable!).and_return(nil) # Make sure not really enabled.
  end

  context "when in production" do
    before do
      allow(Rails).to receive(:env) { 'production'.inquiry }
    end

    it "puts a notice to stdout" do
      expect($stdout).to receive(:puts).with("`DevMonkeyPatches` was enabled in production!".red)
      described_class.enable
      expect(respond_to?(:dev_dev_mixed_in?)).to eq false
    end
  end

  context "when in test" do
    it "is not enabled by default" do
      allow($stdout).to receive(:puts).and_return(nil) # Just swallow message.
      described_class.enable
      expect(respond_to?(:dev_dev_mixed_in?)).to eq false
    end

    it "puts a notice to stdout" do
      expect($stdout).to receive(:puts).with("`DevMonkeyPatches` was enabled in test!".red)
      described_class.enable
      expect(respond_to?(:dev_dev_mixed_in?)).to eq false
    end
  end
end
