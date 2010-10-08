require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe OtherReference do
  describe "importing" do
    it "should create the reference and set its data" do
      ward_reference = Factory(:ward_reference)
      reference = OtherReference.import(
        {:authors => [Factory(:author)], :title => 'awdf',
          :source_reference_id => ward_reference.id, :source_reference_type => 'WardReference', :citation_year => '2010'},
        'Citation')
      reference.citation.should == 'Citation'
      reference.source_reference.should == ward_reference
    end
  end

  describe "citation_string" do
    it "should format a citation_string" do
      reference = OtherReference.new :citation => 'Citation'
      reference.citation_string.should == 'Citation.'
    end
  end

  describe "validation" do
    before do
      author = Factory :author
      @reference = OtherReference.new :authors => [author], :title => 'Title', :citation_year => '2010a',
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

end
