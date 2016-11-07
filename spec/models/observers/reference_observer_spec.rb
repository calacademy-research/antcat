require 'spec_helper'

describe ReferenceObserver do
  describe "nested refererences" do
    context "when a nesting_reference is changed" do
      it "invalidates the cache for it and the nestee" do
        nesting_reference = create :article_reference
        nesting_reference.title = 'title'
        ReferenceFormatterCache.instance.populate nesting_reference
        nestee = create :nested_reference, nesting_reference: nesting_reference
        ReferenceFormatterCache.instance.populate nestee
        nesting_reference.title = 'Title'
        nesting_reference.save!

        nesting_reference.reload
        nestee.reload

        # TODO check that is wasn't nil all the time.
        expect(nesting_reference.formatted_cache).to be_nil
        expect(nestee.formatted_cache).to be_nil
      end
    end
  end

  context "when a reference document is changed" do
    it "invalidates the cache for the document's reference" do
      reference = create :article_reference
      reference_document = create :reference_document, reference: reference
      ReferenceFormatterCache.instance.populate reference
      ReferenceFormatterCache.instance.invalidate reference
      ReferenceObserver.instance.before_update reference
      reference.reload

      # TODO check that is wasn't nil all the time.
      expect(reference.formatted_cache).to be_nil
    end
  end
end
