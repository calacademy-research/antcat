require 'spec_helper'

describe ReferenceObserver do
  let(:reference) { create :article_reference }

  describe "nested references" do
    context "when a nesting_reference is changed" do
      it "invalidates the cache for itself and its nestees" do
        # Setup.
        nestee = create :nested_reference, nesting_reference: reference

        reference.reload
        nestee.reload
        ReferenceFormatterCache.populate reference
        ReferenceFormatterCache.populate nestee
        expect(reference.formatted_cache).to_not be_nil
        expect(nestee.formatted_cache).to_not be_nil

        # Act and test.
        reference.title = 'New Title'
        reference.save!

        # Need to reload in spec, or we get the old values.
        reference.reload
        nestee.reload

        expect(reference.formatted_cache).to be_nil
        expect(nestee.formatted_cache).to be_nil
      end
    end
  end

  context "when a reference document is changed" do
    it "invalidates the cache for the document's reference" do
      # Setup.
      reference_document = create :reference_document, reference: reference
      reference.reload
      ReferenceFormatterCache.populate reference
      expect(reference.formatted_cache).to_not be_nil

      # Act and test.
      ReferenceObserver.instance.before_update reference
      reference.reload
      expect(reference.formatted_cache).to be_nil
    end
  end
end
