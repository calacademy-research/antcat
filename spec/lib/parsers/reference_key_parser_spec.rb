# coding: UTF-8
require 'spec_helper'

describe Parsers::ReferenceKeyParser do
  before do
    @parser = Parsers::ReferenceKeyParser
  end

  describe "Parsing a key string into its components" do
    it "should return an author and a year" do
      @parser.parse('Bolton, 1975').should == {author_last_names: ['Bolton'], nester_last_names: nil,  year: '1975', year_ordinal: nil}
    end
    it "should return a year ordinal" do
      @parser.parse('Bolton, 1975b').should == {author_last_names: ['Bolton'], nester_last_names: nil,  year: '1975', year_ordinal: 'b'}
    end
    it "should return two authors" do
      @parser.parse('Bolton & Fisher, 1975').should == {author_last_names: ['Bolton', 'Fisher'], nester_last_names: nil, year: '1975', year_ordinal: nil}
    end
    it "should handle et al." do
      @parser.parse('Bolton, <i>et al.</i> 1975').should == {author_last_names: ['Bolton'], nester_last_names: nil, year: '1975', year_ordinal: nil}
    end
    it "should handle three or more items" do
      @parser.parse('Bolton, Fisher & Ward, 1975').should == {author_last_names: ['Bolton', 'Fisher', 'Ward'], nester_last_names: nil, year: '1975', year_ordinal: nil}
    end
    it "should handle it when the year is missing" do
      @parser.parse('Bolton').should == {author_last_names: ['Bolton'], nester_last_names: nil, year: nil, year_ordinal: nil}
    end
  end

end
