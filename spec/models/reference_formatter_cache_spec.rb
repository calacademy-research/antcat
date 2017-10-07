require 'spec_helper'

describe ReferenceFormatterCache do
  it "is a singleton" do
    expect { described_class.new }.to raise_error(/private method/)
    expect(described_class.instance).to eq described_class.instance
  end

  describe "#regenerate" do
    let!(:reference) { create :article_reference }

    it "calls ReferenceFormatter to get the value" do
      expect(reference.formatted_cache).to be_nil
      expect(reference.inline_citation_cache).to be_nil

      decorated = reference.decorate
      generated_formatted_cache = decorated.send :generate_formatted
      generated_inline_citation_cache = decorated.send :generate_inline_citation

      described_class.populate reference

      expect(reference.formatted_cache).to eq generated_formatted_cache
      expect(reference.inline_citation_cache).to eq generated_inline_citation_cache
    end
  end
end
