require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe BookReference do

  describe "importing a new reference" do
    it "should create and return a BookReference with the passed-in data" do
      data = {:authors => 'Fisher, B.L.', :year => 2010, :title => 'Title',
        :book => {
          :publisher => {:name => 'CSIRO Publications', :place => 'Melbourne'},
          :pagination => 'vii + 70 pp.'
        }}

      book = mock_model Book
      Book.should_receive(:import).with(data).and_return book

      reference = BookReference.import data
      BookReference.first.should == reference
      reference.book.should == book
    end

    it "should find an existing book" do
      book = Book.create!(
        :authors => 'Fisher, B.L.', :year => 2010, :title => 'Ants', :place => 'New York',
        :publisher => 'Oxford', :pagination => '32 pp.')
      BookReference.import :authors => 'Fisher, B.L.', :year => 2010, :title => 'Ants',
        :book => {
          :publisher => {:name => 'Oxford', :place => 'New York'},
          :pagination => '32 pp.'
        }
      BookReference.first.book.should == book
    end
  end
end
