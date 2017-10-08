require "spec_helper"

describe References::Cache::Regenerate do
  describe "#call" do
    let!(:reference) { create :article_reference }

    it "calls `ReferenceDecorator` to get the value" do
      expect(reference.formatted_cache).to be_nil
      expect(reference.inline_citation_cache).to be_nil

      decorated = reference.decorate
      generated_formatted_cache = decorated.send :generate_formatted
      generated_inline_citation_cache = decorated.send :generate_inline_citation

      described_class[reference]

      expect(reference.formatted_cache).to eq generated_formatted_cache
      expect(reference.inline_citation_cache).to eq generated_inline_citation_cache
    end
  end
end
