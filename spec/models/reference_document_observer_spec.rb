# coding: UTF-8
require 'spec_helper'

describe ReferenceDocumentObserver do
  it "should invalidate the cache for the reference that uses the reference document" do
    reference = FactoryGirl.create :article_reference
    reference_document = FactoryGirl.create :reference_document, reference: reference
    reference.populate_cache
    ReferenceDocumentObserver.instance.before_update reference_document
    reference.formatted_cache.should be_nil
  end
  it "shouldn't croak if there's no reference" do
    reference_document = FactoryGirl.create :reference_document
    ReferenceDocumentObserver.instance.before_update reference_document
  end
end
