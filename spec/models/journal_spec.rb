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
end
