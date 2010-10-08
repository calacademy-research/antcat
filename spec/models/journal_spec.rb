require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Journal do
  describe "importing from a new record" do
    it "should create and return the journal" do
      Journal.import(:title => 'Antucopia').title.should == 'Antucopia'
    end

    it "should reuse an existing journal" do
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

    it "should require matching the first letter" do
      Factory(:journal, :title => 'ABC')
      Journal.search('BC').should == []
    end

    it "should return results in order of most used" do
      ['Most Used', 'Never Used', 'Occasionally Used', 'Rarely Used'].each do |title|
        Factory :journal, :title => title
      end
      2.times {Factory :article_reference, :journal => Journal.find_by_title('Rarely Used')}
      3.times {Factory :article_reference, :journal => Journal.find_by_title('Occasionally Used')}
      4.times {Factory :article_reference, :journal => Journal.find_by_title('Most Used')}
      0.times {Factory :article_reference, :journal => Journal.find_by_title('Never Used')}

      Journal.search.should == ['Most Used', 'Occasionally Used', 'Rarely Used', 'Never Used']
    end
  end

  describe 'validation' do
    it 'should require a title' do
      Journal.new.should_not be_valid
      Journal.new(:title => 'title').should be_valid
    end
  end

end
