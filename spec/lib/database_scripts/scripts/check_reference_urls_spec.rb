require "spec_helper"

describe DatabaseScripts::Scripts::CheckReferenceUrls do
  let(:script) { DatabaseScripts::Scripts::CheckReferenceUrls.new }

  context "when in production" do
    before { allow(Rails.env).to receive(:development?).and_return false }

    it "it cannot be run" do
      expect(script.render).to include "can only be run in the dev"
      expect(script.render).to_not include "0 processed in 1 min"
    end
  end

  context "when in development" do
    before { allow(Rails.env).to receive(:development?).and_return true }

    it "can be run" do
      expect(script.render).to include "0 processed in 1 min"
    end
  end
end
