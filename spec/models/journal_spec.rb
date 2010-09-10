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

  describe "importing from an existing record" do
    it "should not change anything if the title doesn't change" do
      journal = Journal.create! :title => 'Ants'
      issue = Issue.create! :journal => journal
      journal.import(:title => 'Ants').should == journal
    end
    it "should delete itself and return a new one if the title did change" do
      journal = Journal.create! :title => 'Ants'
      issue = Issue.create! :journal => journal
      new_journal = journal.import :title => 'Bees'
      new_journal.should_not == journal
      new_journal.title.should == 'Bees'
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
