# coding: UTF-8
require 'spec_helper'

describe MissingReferenceKey do

  describe "Link" do
    it "should simply output its citation" do
      key = MissingReferenceKey.new("citation")
      key.to_link.should == 'citation'
    end
  end

  describe "Unapplicable methods" do
    it "should just return nil from them" do
      key = MissingReferenceKey.new('citation')
      key.document_link(FactoryGirl.create :user).should be_nil
      key.goto_reference_link.should be_nil
    end
  end

end
