require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Source do
  it "has many authors" do
    source = Source.create!

    author = Author.create! :name => 'Fisher, B.L.'
    source.authors << author

    source.authors.first.should == author
  end
end
