# coding: UTF-8
require 'spec_helper'

describe ReferenceFormatterCache do
  it "is a singleton" do
    -> {ReferenceFormatterCache.new}.should raise_error
    ReferenceFormatterCache.instance.should ==  ReferenceFormatterCache.instance
  end
  describe "Invalidating" do
    it "should do nothing if there's nothing in the cache" do
      reference = FactoryGirl.create :article_reference
      reference.formatted_cache.should be_nil
      reference.inline_citation_cache.should be_nil
      ReferenceFormatterCache.instance.invalidate reference
      reference.formatted_cache.should be_nil
      reference.inline_citation_cache.should be_nil
    end
    it "should set the cache to nil" do
      reference = FactoryGirl.create :article_reference
      ReferenceFormatterCache.instance.populate reference
      reference.formatted_cache.should_not be_nil
      reference.inline_citation_cache.should_not be_nil
      ReferenceFormatterCache.instance.invalidate reference
      reference.formatted_cache.should be_nil
      reference.inline_citation_cache.should be_nil
    end

  end

  describe "Filling" do
    describe "Populating" do
      it "should call ReferenceFormatter to get the value" do
        reference = FactoryGirl.create :article_reference
        reference.formatted_cache.should be_nil
        reference.inline_citation_cache.should be_nil

        user = double
        formatter = Formatters::ReferenceFormatter.new(reference)
        formatted_cache_value = Formatters::ReferenceFormatter.format! reference
        inline_citation_cache_value = formatter.format_inline_citation! user

        reference.formatted_cache.should == formatted_cache_value
        reference.inline_citation_cache.should be_nil
        ReferenceFormatterCache.instance.populate reference
        reference.formatted_cache.should == formatted_cache_value
        reference.inline_citation_cache.should == inline_citation_cache_value
      end
    end
    describe "Setting/getting" do
      it "should get and set the right values" do
        reference = FactoryGirl.create :article_reference
        ReferenceFormatterCache.instance.set reference, 'Cache', :formatted_cache
        ReferenceFormatterCache.instance.get(reference, :formatted_cache).should == 'Cache'
      end
    end
  end

  describe "Handling a network" do
    it "should invalidate each member of the network" do
      nesting_reference = FactoryGirl.create :article_reference
      ReferenceFormatterCache.instance.populate nesting_reference
      ReferenceFormatterCache.instance.get(nesting_reference).should_not be_nil

      nested_reference = FactoryGirl.create :nested_reference, nesting_reference: nesting_reference
      ReferenceFormatterCache.instance.populate nested_reference
      ReferenceFormatterCache.instance.get(nested_reference).should_not be_nil

      author_name = FactoryGirl.create :author_name
      reference_author_name = FactoryGirl.create :reference_author_name, reference: nesting_reference, author_name: author_name
      reference_author_name.position = 4
      reference_author_name.save!

      ReferenceFormatterCache.instance.get(nesting_reference).should be_nil
      ReferenceFormatterCache.instance.get(nested_reference).should be_nil
    end
  end

end
