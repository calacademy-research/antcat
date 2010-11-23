require 'spec_helper'

describe UnknownReference do
  describe "importing" do
    it "should create the reference and set its data" do
      ward_reference = Factory(:ward_reference)
      reference = UnknownReference.import(
        {:author_names => [Factory(:author_name)], :title => 'awdf',
          :source_reference_id => ward_reference.id, :source_reference_type => 'Ward::Reference', :citation_year => '2010'},
        'Citation')
      reference.citation.should == 'Citation'
      reference.source_reference.should == ward_reference
    end
  end

  describe "validation" do
    before do
      author_name = Factory :author_name
      @reference = UnknownReference.new :author_names => [author_name], :title => 'Title', :citation_year => '2010a',
        :citation => 'Citation'
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
