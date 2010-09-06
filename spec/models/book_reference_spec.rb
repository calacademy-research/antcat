require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe BookReference do

  describe "importing a new reference" do
    it "should create and return a BookReference with the passed-in data" do
      book = mock_model Book
      Book.should_receive(:import).with({}).and_return book

      reference = BookReference.import({})

      BookReference.first.should == reference
      reference.book.should == book
    end

  end
end
