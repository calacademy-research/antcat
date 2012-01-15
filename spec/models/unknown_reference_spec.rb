# coding: UTF-8
require 'spec_helper'

describe UnknownReference do

  describe "validation" do
    before do
      author_name = Factory :author_name
      @reference = UnknownReference.new author_names: [author_name], title: 'Title', citation_year: '2010a',
        citation: 'Citation'
    end
    it "should be be valid the way I set it up" do
      @reference.should be_valid
    end
    it "should be not be valid without a citation" do
      @reference.citation = nil
      @reference.should_not be_valid
    end
  end

  describe "entering a newline in the citation" do
    it "should strip the newline" do
      reference = Factory :unknown_reference
      reference.title = "A\nB"
      reference.citation = "A\nB"
      reference.save!
      reference.title.should == "A B"
      reference.citation.should == "A B"
    end
  end

end
