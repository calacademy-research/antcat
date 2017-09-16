require "spec_helper"

describe References::Cache::Set do
  describe "#call" do
    let!(:reference) { create :article_reference }

    it "gets and sets the right values" do
      described_class[reference, 'Cache', :formatted_cache]
      reference.reload

      expect(reference.formatted_cache).to eq 'Cache'
    end
  end
end
