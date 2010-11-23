require 'spec_helper'

describe Ward::JournalParser do

  it "should extract the journal title from the beginning of a citation" do
    string = "Nature 23:1"
    Ward::JournalParser.parse(string).should == 'Nature'
    string.should == '23:1'
  end

end

