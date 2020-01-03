require 'rails_helper'

describe References::Cache::Regenerate do
  describe "#call" do
    let!(:reference) { create :article_reference }

    it "calls `ReferenceDecorator` to get the value" do
      expect(reference.plain_text_cache).to eq nil
      expect(reference.expandable_reference_cache).to eq nil
      expect(reference.expanded_reference_cache).to eq nil

      decorated = reference.decorate
      generated_plain_text_cache = decorated.send :generate_plain_text
      generated_expandable_reference_cache = decorated.send :generate_expandable_reference
      generated_expanded_reference_cache = decorated.send :generate_expanded_reference

      described_class[reference]

      expect(reference.plain_text_cache).to eq generated_plain_text_cache
      expect(reference.expandable_reference_cache).to eq generated_expandable_reference_cache
      expect(reference.expanded_reference_cache).to eq generated_expanded_reference_cache
    end
  end
end
