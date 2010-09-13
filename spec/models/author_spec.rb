require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Author do
  it "has many references" do
    author = Author.create! :name => 'Fisher, B.L.'

    reference = Factory(:reference)
    author.references << reference

    author.references.first.should == reference
  end

  describe "importing" do
    it "should create and return the authors" do
      Author.import(['Fisher, B.L.', 'Wheeler, W.M.']).map(&:name).should =~
      ['Fisher, B.L.', 'Wheeler, W.M.']
    end

    it "should reuse existing authors" do
      Author.import(['Fisher, B.L.', 'Wheeler, W.M.'])
      Author.import(['Fisher, B.L.', 'Wheeler, W.M.'])
      Author.count.should == 2
    end
  end

end
