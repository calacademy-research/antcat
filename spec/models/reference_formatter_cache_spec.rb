require 'spec_helper'

describe ReferenceFormatterCache do
  it "is a singleton" do
    expect { ReferenceFormatterCache.new }.to raise_error
    expect(ReferenceFormatterCache.instance).to eq ReferenceFormatterCache.instance
  end

  describe "#invalidate" do
    let(:reference) { create :article_reference }

    it "does nothing if there's nothing in the cache" do
      expect(reference.formatted_cache).to be_nil
      expect(reference.inline_citation_cache).to be_nil

      ReferenceFormatterCache.invalidate reference
      expect(reference.formatted_cache).to be_nil
      expect(reference.inline_citation_cache).to be_nil
    end

    it "sets the cache to nil" do
      ReferenceFormatterCache.populate reference
      expect(reference.formatted_cache).not_to be_nil
      expect(reference.inline_citation_cache).not_to be_nil

      ReferenceFormatterCache.invalidate reference
      expect(reference.formatted_cache).to be_nil
      expect(reference.inline_citation_cache).to be_nil
    end
  end

  describe "Filling" do
    describe "#populate" do
      it "calls ReferenceFormatter to get the value" do
        reference = create :article_reference

        expect(reference.formatted_cache).to be_nil
        expect(reference.inline_citation_cache).to be_nil

        decorated = reference.decorate
        formatted_cache_value = decorated.format!
        inline_citation_cache_value = decorated.to_link

        expect(reference.formatted_cache).to eq formatted_cache_value
        expect(reference.inline_citation_cache).to be_nil
        ReferenceFormatterCache.populate reference
        expect(reference.formatted_cache).to eq formatted_cache_value
        expect(reference.inline_citation_cache).to eq inline_citation_cache_value
      end
    end

    describe "#get and #set" do
      it "gets and sets the right values" do
        reference = create :article_reference
        ReferenceFormatterCache.set reference, 'Cache', :formatted_cache
        reference.reload

        expect(reference.formatted_cache).to eq 'Cache'
      end
    end
  end

  describe "Handling a network" do
    it "invalidates each member of the network" do
      nesting_reference = create :article_reference
      ReferenceFormatterCache.populate nesting_reference
      nesting_reference.reload
      expect(nesting_reference.formatted_cache).not_to be_nil

      nested_reference = create :nested_reference, nesting_reference: nesting_reference
      ReferenceFormatterCache.populate nested_reference
      nested_reference.reload
      expect(nested_reference.formatted_cache).not_to be_nil

      author_name = create :author_name
      reference_author_name = create :reference_author_name, reference: nesting_reference, author_name: author_name
      reference_author_name.position = 4
      reference_author_name.save!
      nesting_reference.reload
      nested_reference.reload

      expect(nesting_reference.formatted_cache).to be_nil
      expect(nested_reference.formatted_cache).to be_nil
    end
  end
end
