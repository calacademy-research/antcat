# coding: UTF-8
require 'spec_helper'

describe AuthorNameObserver do
  describe "Invalidating the formatted cache" do
    it "should invalidate the cache when a change occurs" do
      bolton = FactoryGirl.create :author_name, name: 'Bolton'
      AuthorNameObserver.any_instance.should_receive :after_update
      bolton.name = 'Fisher'
      bolton.save!
    end

    it "should invalidate the cache for all references that use the data" do
      bolton = FactoryGirl.create :author_name, name: 'Bolton'
      fisher = FactoryGirl.create :author_name, name: 'Fisher'
      fisher_reference = FactoryGirl.create :article_reference, author_names: [fisher]
      fisher_reference.populate_cache
      fisher_reference.reload.formatted_cache.should_not be_nil

      bolton_reference1 = FactoryGirl.create :article_reference, author_names: [bolton]
      bolton_reference1.populate_cache
      bolton_reference1.reload.formatted_cache.should_not be_nil

      bolton_reference2 = FactoryGirl.create :article_reference, author_names: [bolton]
      bolton_reference2.populate_cache
      bolton_reference2.reload.formatted_cache.should_not be_nil

      AuthorNameObserver.instance.after_update bolton

      bolton_reference1.reload.formatted_cache.should be_nil
      bolton_reference2.reload.formatted_cache.should be_nil
      fisher_reference.reload.formatted_cache.should_not be_nil
    end

  end
end
