require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Journal do

  describe "searching" do
    it "do fuzzy matching of journal names" do
      Factory.create(:reference, :citation => 'American Bibliographic Proceedings 1:2')
      Factory.create(:reference, :citation => 'Playboy 1:2')
      Journal.search('ABP').should == ['American Bibliographic Proceedings']
    end
    it "should only return one journal title per journal" do
      Factory.create(:reference, :citation => 'American Bibliographic Proceedings 1:2')
      Factory.create(:reference, :citation => 'American Bibliographic Proceedings 1:2')
      Journal.search('ABP').should == ['American Bibliographic Proceedings']
    end
  end

end
