require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Journal do
  describe "importing" do
    it "should create and return the journal" do
      Journal.import(:title => 'Antucopia').title.should == 'Antucopia'
    end

    it "should reuse and existing journal" do
      Journal.import(:title => 'Antucopia')
      Journal.import(:title => 'Antucopia')
      Journal.count.should == 1
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
