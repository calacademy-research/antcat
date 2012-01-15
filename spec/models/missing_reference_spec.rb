# coding: UTF-8
require 'spec_helper'

describe MissingReference do

  describe "Importing" do
    it "should create the reference based on the passed data" do
      reference = MissingReference.import 'no Bolton', author_names: ['Bolton'], year: '1920', reference_text: 'Bolton, 1920: 22'
      reference.reload.year.should == 1920
      reference.citation.should == 'Bolton, 1920'
      reference.reason_missing.should == 'no Bolton'
    end
    it "should save the whole thing in the citation if there's no colon" do
      reference = MissingReference.import 'no Bolton', author_names: ['Bolton'], year: '1920', reference_text: 'Bolton, 1920'
      reference.reload.year.should == 1920
      reference.citation.should == 'Bolton, 1920'
      reference.reason_missing.should == 'no Bolton'
    end
  end

  describe "Key" do
    it "has its own kind of key" do
      reference = Factory :missing_reference
      reference.key.should be_kind_of MissingReferenceKey
    end
  end

end
