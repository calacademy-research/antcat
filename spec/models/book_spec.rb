require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Book do
  it "has authors" do
    author = Author.create! :name => 'Fisher, B.L.'
    book = Book.create!

    book.authors << author

    book.reload.authors.should == [author.reload]
  end

  describe "importing" do
    it "should create the book and set its authors and other information" do
      book = Book.import({:authors => ['Fisher, B.L.', 'Wheeler, W.M.'], :year => 2010, :title => 'Ants',
        :book => {:publisher => {:place => 'New York', :name => 'Oxford'}, :pagination => '26 pp'}})
      book.authors.map(&:name).should =~ ['Fisher, B.L.', 'Wheeler, W.M.']
      book.year.should == 2010
      book.title.should == 'Ants'
      book.place.should == 'New York'
      book.publisher.should == 'Oxford'
      book.pagination.should == '26 pp'
    end
  end
end
