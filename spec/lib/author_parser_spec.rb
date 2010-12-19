require 'spec_helper'

describe AuthorParser do

  describe "parsing first name and initials and last name" do
    it "should return an empty hash if the string is empty" do
      ['', nil].each do |string|
        AuthorParser.get_name_parts(string).should == {}
      end
    end
    it "should simply return the name if there's only one word" do
      AuthorParser.get_name_parts('Bolton').should == {:last => 'Bolton'}
    end
    it "should separate the words if there are multiple" do
      AuthorParser.get_name_parts('Bolton, B.L.').should == {:last => 'Bolton', :first_and_initials => 'B.L.'}
    end
    it "should use all words if there is no comma" do
      AuthorParser.get_name_parts('Royal Academy').should == {:last => 'Royal Academy'}
    end
    it "should use use all words before the comma if there are multiple" do
      AuthorParser.get_name_parts('Baroni Urbani, C.').should == {:last => 'Baroni Urbani', :first_and_initials => 'C.'}
    end
  end

end
