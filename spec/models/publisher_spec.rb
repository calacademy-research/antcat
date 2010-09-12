require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Publisher do

  describe "importing" do
    it "should create and return the publisher" do
      publisher = Publisher.import(:name => 'Wiley', :place => 'Chicago')
      publisher.name.should == 'Wiley'
      publisher.place.should == 'Chicago'
    end

    it "should reuse an existing publisher" do
      2.times {Publisher.import(:name => 'Wiley', :place => 'Chicago')}
      Publisher.count.should == 1
    end
  end

  describe "searching" do
    it "should do fuzzy matching of journal names" do
      Factory(:journal, :title => 'American Bibliographic Proceedings')
      Factory(:journal, :title => 'Playboy')
      Journal.search('ABP').should == ['American Bibliographic Proceedings']
    end
  end

end
