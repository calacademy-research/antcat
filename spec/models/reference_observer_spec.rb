require 'spec_helper'

describe ReferenceObserver do

  describe "Nested refererences" do
    describe "Formatted reference cache" do
      describe "Invalidating the cache" do
        it "When the nesting_reference changes, it and the nestee should be invalidated" do
          nesting_reference = FactoryGirl.create :article_reference
          nesting_reference.title = 'title'
          ReferenceFormatterCache.instance.populate nesting_reference
          nestee = FactoryGirl.create :nested_reference, nesting_reference: nesting_reference
          ReferenceFormatterCache.instance.populate nestee
          nesting_reference.title = 'Title'
          nesting_reference.save!
          expect(ReferenceFormatterCache.instance.get(nesting_reference)).to be_nil
          expect(ReferenceFormatterCache.instance.get(nestee)).to be_nil
        end
        it "should invalidate the cache for the reference that uses the reference document" do
          nesting_reference = FactoryGirl.create :article_reference
          nestee = FactoryGirl.create :nested_reference, nesting_reference: nesting_reference
          reference = FactoryGirl.create :article_reference
          reference_document = FactoryGirl.create :reference_document, reference: reference
          ReferenceFormatterCache.instance.populate reference
          ReferenceFormatterCache.instance.invalidate reference
          ReferenceObserver.instance.before_update reference
          expect(reference.formatted_cache).to be_nil
          expect(ReferenceFormatterCache.instance.get(reference)).to be_nil
        end
      end
    end
  end

end
