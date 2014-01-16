# coding: UTF-8
require 'spec_helper'

describe ReferenceAuthorNameObserver do
  it "should be asked to invalidate the cache when a change occurs" do
    reference = FactoryGirl.create :article_reference
    author_name = FactoryGirl.create :author_name
    reference_author_name = FactoryGirl.create :reference_author_name, reference: reference, author_name: author_name
    ReferenceAuthorNameObserver.any_instance.should_receive :before_save
    reference_author_name.position = 4
    reference_author_name.save!
  end

  it "should invalidate the cache for the reference involved when a reference_author_name is added" do
    reference = FactoryGirl.create :article_reference
    ReferenceFormatterCache.instance.populate reference
    reference.reference_author_names.create! position: 1, author_name: FactoryGirl.create(:author_name)
    ReferenceFormatterCache.instance.get(reference).should be_nil
  end
  it "should invalidate the cache for the reference involved when a reference_author_name is changed" do
    reference = FactoryGirl.create :article_reference
    reference.reference_author_names.create! position: 1, author_name: FactoryGirl.create(:author_name)
    ReferenceFormatterCache.instance.populate reference
    reference.reference_author_names.first.update_attribute :position, 1000
    ReferenceFormatterCache.instance.get(reference).should be_nil
  end
  it "should invalidate the cache for the reference involved when a reference_author_name is deleted" do
    reference = FactoryGirl.create :article_reference
    reference.reference_author_names.create! position: 1, author_name: FactoryGirl.create(:author_name)
    ReferenceFormatterCache.instance.populate reference
    reference.reference_author_names.first.destroy
    ReferenceFormatterCache.instance.get(reference).should be_nil
  end
end
