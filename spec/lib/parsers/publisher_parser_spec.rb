# coding: UTF-8
require 'spec_helper'

describe Parsers::PublisherParser do
  before do
    @parser = Parsers::PublisherParser
  end

  describe "getting the place and name" do

    it "should return nil if the string is unparseable" do
      @parser.parse('New York').should be_nil
    end

    it "should parse it correctly" do
      @parser.parse('New York: Houghton Mifflin').should ==
        {:publisher => {:name => 'Houghton Mifflin', :place => 'New York'}}
    end

    it "should not consider a single digit as a place" do
      @parser.parse('5: Rest').should be_nil
    end
    it "or two letters" do
      @parser.parse('Ab: Rest').should be_nil
    end
    it "or even three letters" do
      @parser.parse('Abc: Rest').should_not be_nil
    end

  end

end
