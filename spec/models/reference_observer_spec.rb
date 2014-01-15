# coding: UTF-8
require 'spec_helper'

describe ReferenceObserver do

  describe "Nested refererences" do
    describe "Formatted reference cache" do
      describe "Invalidating the cache" do
        it "When the nester changes, it and the nestee should be invalidated" do
          nester = FactoryGirl.create :article_reference
          nester.title = 'title'
          nester.populate_cache
          nestee = FactoryGirl.create :nested_reference, nested_reference: nester
          nestee.populate_cache
          nester.title = 'Title'
          nester.save!
          ReferenceFormatterCache.instance.get(nester).should be_nil
          ReferenceFormatterCache.instance.get(nestee).should be_nil
        end
        it "should invalidate the cache for the reference that uses the reference document" do
          nester = FactoryGirl.create :article_reference
          nestee = FactoryGirl.create :nested_reference, nested_reference: nester
          reference = FactoryGirl.create :article_reference
          reference_document = FactoryGirl.create :reference_document, reference: reference
          reference.populate_cache
          ReferenceFormatterCache.instance.invalidate reference
          ReferenceObserver.instance.before_update reference
          reference.formatted_cache.should be_nil
          ReferenceFormatterCache.instance.get(reference).should be_nil
        end
      end
    end
  end

end
