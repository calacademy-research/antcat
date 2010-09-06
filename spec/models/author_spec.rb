require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Author do
  it "has a source" do
    author = Author.create! :name => 'Fisher, B.L.'
    book = Book.create!

    author.source = book
    author.save!

    author.reload.source.should == book
  end

  describe "importing" do
    it "should create and return the authors" do
      Author.import(['Fisher, B.L.', 'Wheeler, W.M.']).map(&:name).should =~
      ['Fisher, B.L.', 'Wheeler, W.M.']
    end
  end
end
