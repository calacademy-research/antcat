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
      ReferenceFormatterCache.instance.get(reference).should be_nil
      ReferenceFormatterCache.instance.invalidate reference
      ReferenceFormatterCache.instance.get(reference).should be_nil
    end
    it "should set the cache to nil" do
      reference = FactoryGirl.create :article_reference
      ReferenceFormatterCache.instance.populate reference
      ReferenceFormatterCache.instance.get(reference).should_not be_nil
      ReferenceFormatterCache.instance.invalidate reference
      ReferenceFormatterCache.instance.get(reference).should be_nil
    end

  end

  describe "Filling" do
    describe "Populating" do
      it "should call ReferenceFormatter to get the value" do
        reference = FactoryGirl.create :article_reference
        ReferenceFormatterCache.instance.get(reference).should be_nil
        value = Formatters::ReferenceFormatter.format reference, false
        ReferenceFormatterCache.instance.get(reference).should be_nil
        ReferenceFormatterCache.instance.populate reference
        ReferenceFormatterCache.instance.get(reference).should == value
      end
    end
    describe "Setting" do
      it "should call set the cache to the desired value" do
        reference = FactoryGirl.create :article_reference
        ReferenceFormatterCache.instance.set(reference, 'Cache')
        ReferenceFormatterCache.instance.get(reference).should == 'Cache'
      end
    end
  end
end
