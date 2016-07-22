require 'spec_helper'

describe ReferenceFormatterCache do
  it "is a singleton" do
    expect { ReferenceFormatterCache.new }.to raise_error
    expect(ReferenceFormatterCache.instance).to eq ReferenceFormatterCache.instance
  end

  describe "Invalidating" do
    it "should do nothing if there's nothing in the cache" do
      reference = create :article_reference
      expect(reference.formatted_cache).to be_nil
      expect(reference.inline_citation_cache).to be_nil
      ReferenceFormatterCache.instance.invalidate reference
      expect(reference.formatted_cache).to be_nil
      expect(reference.inline_citation_cache).to be_nil
    end

    it "should set the cache to nil" do
      reference = create :article_reference
      ReferenceFormatterCache.instance.populate reference
      expect(reference.formatted_cache).not_to be_nil
      expect(reference.inline_citation_cache).not_to be_nil
      ReferenceFormatterCache.instance.invalidate reference
      expect(reference.formatted_cache).to be_nil
      expect(reference.inline_citation_cache).to be_nil
    end
  end

  describe "Filling" do
    describe "Populating" do
      it "should call ReferenceFormatter to get the value" do
        reference = create :article_reference
        expect(reference.formatted_cache).to be_nil
        expect(reference.inline_citation_cache).to be_nil

        decorated = reference.decorate
        formatted_cache_value = decorated.format!
        inline_citation_cache_value = decorated.format_inline_citation!

        expect(reference.formatted_cache).to eq formatted_cache_value
        expect(reference.inline_citation_cache).to be_nil
        ReferenceFormatterCache.instance.populate reference
        expect(reference.formatted_cache).to eq formatted_cache_value
        expect(reference.inline_citation_cache).to eq inline_citation_cache_value
      end
    end

    describe "Setting/getting" do
      it "should get and set the right values" do
        reference = create :article_reference
        ReferenceFormatterCache.instance.set reference, 'Cache', :formatted_cache
        expect(ReferenceFormatterCache.instance.get(reference, :formatted_cache)).to eq 'Cache'
      end
    end
  end

  describe "Handling a network" do
    it "should invalidate each member of the network" do
      nesting_reference = create :article_reference
      ReferenceFormatterCache.instance.populate nesting_reference
      expect(ReferenceFormatterCache.instance.get(nesting_reference)).not_to be_nil

      nested_reference = create :nested_reference, nesting_reference: nesting_reference
      ReferenceFormatterCache.instance.populate nested_reference
      expect(ReferenceFormatterCache.instance.get(nested_reference)).not_to be_nil

      author_name = create :author_name
      reference_author_name = create :reference_author_name, reference: nesting_reference, author_name: author_name
      reference_author_name.position = 4
      reference_author_name.save!

      expect(ReferenceFormatterCache.instance.get(nesting_reference)).to be_nil
      expect(ReferenceFormatterCache.instance.get(nested_reference)).to be_nil
    end
  end
end
