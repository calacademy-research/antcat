# coding: UTF-8
require 'spec_helper'

describe FormattedReferenceCache do

  describe "Caching" do
    it "should cache" do
      reference = FactoryGirl.create :reference
      FormattedReferenceCache.set reference, 'string'
      reference.reload.formatted_cache.should == 'string'
    end
    it "should ignore nils" do
      -> {FormattedReferenceCache.set nil, 'string'}.should_not raise_error
    end
  end

  describe "Invalidating the cache" do
    it "should clear the cache" do
      reference = FactoryGirl.create :reference
      FormattedReferenceCache.set reference, 'string'
      FormattedReferenceCache.set reference, nil
      reference.reload.formatted_cache.should be_nil
    end
    it "should ignore nils" do
      -> {FormattedReferenceCache.set nil, 'cache'}.should_not raise_error
    end
  end

end
