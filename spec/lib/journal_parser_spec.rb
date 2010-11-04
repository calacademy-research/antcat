require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe JournalParser do

  it "should extract the journal title from the beginning of a citation" do
    string = "Nature 23:1"
    JournalParser.parse(string).should == 'Nature'
    string.should == '23:1'
  end

end

