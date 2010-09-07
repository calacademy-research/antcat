require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Author do
  it "has many sources" do
    author = Author.create! :name => 'Fisher, B.L.'

    source = Source.create!
    author.sources << source

    author.sources.first.should == source
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
