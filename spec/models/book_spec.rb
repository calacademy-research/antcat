require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Book do

  describe "importing" do
    it "should create the book if it's new" do

      book = Book.import({:authors => 'Fisher, B.L.', :year => 2010, :title => 'Ants',
        :book => {:publisher => {:place => 'New York', :name => 'Oxford'}, :pagination => '26 pp'}})

      book.authors.should == 'Fisher, B.L.'
      book.year.should == 2010
      book.title.should == 'Ants'
      book.place.should == 'New York'
      book.publisher.should == 'Oxford'
      book.pagination.should == '26 pp'
    end

    it "should not create the book if it already exists" do
      Book.create!(:authors => 'Fisher, B.L.', :year => 2010, :title => 'Ants', :place => 'New York', :publisher => 'Oxford',
        :pagination => '26 pp')

      book = Book.import({:authors => 'Fisher, B.L.', :year => 2010, :title => 'Ants',
        :book => {:publisher => {:place => 'New York', :name => 'Oxford'}, :pagination => '26 pp'}})

      Book.count.should == 1
      book.authors.should == 'Fisher, B.L.'
      book.year.should == 2010
      book.title.should == 'Ants'
      book.place.should == 'New York'
      book.publisher.should == 'Oxford'
      book.pagination.should == '26 pp'
    end
  end
end
