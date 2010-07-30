require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Journal do

  describe "searching" do
    it "do fuzzy matching of journal names" do
      Factory(:reference, :journal_title => 'American Bibliographic Proceedings')
      Factory(:reference, :journal_title => 'Playboy')
      Journal.search('ABP').should == ['American Bibliographic Proceedings']
    end
  end

end
