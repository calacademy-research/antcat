require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PublisherParser do

  describe "getting the place and name" do
    it "should return an empty hash if the string is empty" do
      ['', nil].each do |string|
        PublisherParser.get_parts(string).should == {}
      end
    end

    it "should parse it correctly" do
      PublisherParser.get_parts('New York: Houghton Mifflin').should == {:name => 'Houghton Mifflin', :place => 'New York'}
    end

    it "should handle not having a place" do
      PublisherParser.get_parts('Houghton Mifflin').should == {:name => 'Houghton Mifflin', :place => nil}
    end
  end

end
