require "spec_helper"

describe References::Cache::Invalidate do
  describe "#call" do
    let(:reference) { create :article_reference }

    it "does nothing if there's nothing in the cache" do
      expect(reference.formatted_cache).to be_nil
      expect(reference.inline_citation_cache).to be_nil

      described_class[reference]
      expect(reference.formatted_cache).to be_nil
      expect(reference.inline_citation_cache).to be_nil
    end

    it "sets the cache to nil" do
      References::Cache::Regenerate[reference]
      expect(reference.formatted_cache).not_to be_nil
      expect(reference.inline_citation_cache).not_to be_nil

      described_class[reference]
      expect(reference.formatted_cache).to be_nil
      expect(reference.inline_citation_cache).to be_nil
    end
  end
end
