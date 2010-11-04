require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PublisherParser do

  describe "getting the place and name" do

    it "should return nil if the string is unparseable" do
      PublisherParser.parse('New York').should be_nil
    end

    it "should parse it correctly" do
      PublisherParser.parse('New York: Houghton Mifflin').should == {:name => 'Houghton Mifflin', :place => 'New York'}
    end

  end

end
