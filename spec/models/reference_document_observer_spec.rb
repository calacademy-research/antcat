# coding: UTF-8
require 'spec_helper'

describe ReferenceDocumentObserver do
  describe "Invalidating the cache" do
    it "should be asked to invalidate the cache when a change occurs" do
      reference_document = FactoryGirl.create :reference_document
      ReferenceDocumentObserver.any_instance.should_receive :before_update
      reference_document.url = 'antcat.org'
      reference_document.save!
    end
  end

  it "should invalidate the cache for the reference that uses the reference document" do
    reference = FactoryGirl.create :article_reference
    reference_document = FactoryGirl.create :reference_document, reference: reference
    ReferenceFormatterCache.instance.populate reference
    ReferenceDocumentObserver.instance.before_update reference_document
    reference.formatted_cache.should be_nil
  end
  it "shouldn't croak if there's no reference" do
    reference_document = FactoryGirl.create :reference_document
    ReferenceDocumentObserver.instance.before_update reference_document
  end

end
