# coding: UTF-8
require 'spec_helper'

describe AuthorNameObserver do
  describe "Invalidating the formatted cache" do
    it "should invalidate the cache when a change occurs" do
      bolton = FactoryGirl.create :author_name, name: 'Bolton'
      expect_any_instance_of(AuthorNameObserver).to receive :after_update
      bolton.name = 'Fisher'
      bolton.save!
    end

    it "should invalidate the cache for all references that use the data" do
      bolton = FactoryGirl.create :author_name, name: 'Bolton'
      fisher = FactoryGirl.create :author_name, name: 'Fisher'
      fisher_reference = FactoryGirl.create :article_reference, author_names: [fisher]
      ReferenceFormatterCache.instance.populate fisher_reference
      expect(fisher_reference.reload.formatted_cache).not_to be_nil

      bolton_reference1 = FactoryGirl.create :article_reference, author_names: [bolton]
      ReferenceFormatterCache.instance.populate bolton_reference1
      expect(bolton_reference1.reload.formatted_cache).not_to be_nil

      bolton_reference2 = FactoryGirl.create :article_reference, author_names: [bolton]
      ReferenceFormatterCache.instance.populate bolton_reference2
      expect(bolton_reference2.reload.formatted_cache).not_to be_nil

      AuthorNameObserver.instance.after_update bolton

      expect(bolton_reference1.reload.formatted_cache).to be_nil
      expect(bolton_reference2.reload.formatted_cache).to be_nil
      expect(fisher_reference.reload.formatted_cache).not_to be_nil
    end

  end
end
