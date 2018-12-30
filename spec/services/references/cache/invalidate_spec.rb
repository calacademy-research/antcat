require "spec_helper"

describe References::Cache::Invalidate do
  describe "#call" do
    let(:reference) { create :article_reference }

    it "does nothing if there's nothing in the cache" do
      expect(reference.plain_text_cache).to be_nil
      expect(reference.expandable_reference_cache).to be_nil
      expect(reference.expanded_reference_cache).to be_nil

      described_class[reference]
      expect(reference.plain_text_cache).to be_nil
      expect(reference.expandable_reference_cache).to be_nil
      expect(reference.expanded_reference_cache).to be_nil
    end

    it "sets the cache to nil" do
      References::Cache::Regenerate[reference]
      expect(reference.plain_text_cache).not_to be_nil
      expect(reference.expandable_reference_cache).not_to be_nil
      expect(reference.expanded_reference_cache).not_to be_nil

      described_class[reference]
      expect(reference.plain_text_cache).to be_nil
      expect(reference.expandable_reference_cache).to be_nil
      expect(reference.expanded_reference_cache).to be_nil
    end
  end
end
