require 'spec_helper'

describe Ward::PublisherParser do

  describe "getting the place and name" do

    it "should return nil if the string is unparseable" do
      Ward::PublisherParser.parse('New York').should be_nil
    end

    it "should parse it correctly" do
      Ward::PublisherParser.parse('New York: Houghton Mifflin').should ==
        {:publisher => {:name => 'Houghton Mifflin', :place => 'New York'}}
    end

    it "should not consider a single digit as a place" do
      Ward::PublisherParser.parse('5: Rest').should be_nil
    end
    it "or two letters" do
      Ward::PublisherParser.parse('Ab: Rest').should be_nil
    end
    it "or even three letters" do
      Ward::PublisherParser.parse('Abc: Rest').should_not be_nil
    end

  end

end
