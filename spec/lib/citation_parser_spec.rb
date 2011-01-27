require 'spec_helper'

describe CitationGrammar do
  it "should return an empty string if the string is empty" do
    ['', nil].each {|string| CitationParser.parse(string).should be_nil}
  end

  it "should handle an author + year" do
    string = 'Fisher, 2010'
    CitationParser.parse(string).should be_true
    string.should be_empty
  end

  it "should stop after the year" do
    string = 'Santschi, 1936 (<b>unavailable name</b>);'
    CitationParser.parse(string).should be_true
    string.should == '(<b>unavailable name</b>);'
  end

  it "should handle multiple authors" do
    string = 'Espadaler & DuMerle, 1989: 121'
    CitationParser.parse(string).should be_true
    string.should == ': 121'
  end

  it "should handle a missing comma before the year" do
    string = 'Espadaler 1989: 121'
    CitationParser.parse(string).should be_true
    string.should == ': 121'
  end

  it "should handle a letter at the end of the year" do
    string = 'Espadaler 1989b: 121'
    CitationParser.parse(string).should be_true
    string.should == ': 121'
  end

end
