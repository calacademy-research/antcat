# coding: UTF-8
require 'spec_helper'

describe Parsers::ReferenceKeyParser do
  before do
    @parser = Parsers::ReferenceKeyParser
  end

  describe "Parsing a key string into its components" do
    it "should return an author and a year" do
      expect(@parser.parse('Bolton 1975')).to eq({author_last_names: ['Bolton'], nester_last_names: nil,  year: '1975', year_ordinal: nil})
    end
    it "should return a year ordinal" do
      expect(@parser.parse('Bolton, 1975b')).to eq({author_last_names: ['Bolton'], nester_last_names: nil,  year: '1975', year_ordinal: 'b'})
    end
    it "should return two authors" do
      expect(@parser.parse('Bolton & Fisher, 1975')).to eq({author_last_names: ['Bolton', 'Fisher'], nester_last_names: nil, year: '1975', year_ordinal: nil})
    end
    it "should handle et al." do
      expect(@parser.parse('Bolton, <i>et al.</i> 1975')).to eq({author_last_names: ['Bolton'], nester_last_names: nil, year: '1975', year_ordinal: nil})
    end
    it "should handle et al. with two names" do
      expect(@parser.parse('Bolton, Ward <i>et al.</i> 1975')).to eq({author_last_names: ['Bolton', 'Ward'], nester_last_names: nil, year: '1975', year_ordinal: nil})
    end
    it "should handle three or more items" do
      expect(@parser.parse('Bolton, Fisher & Ward, 1975')).to eq({author_last_names: ['Bolton', 'Fisher', 'Ward'], nester_last_names: nil, year: '1975', year_ordinal: nil})
    end
    it "should handle it when the year is missing" do
      expect(@parser.parse('Bolton')).to eq({author_last_names: ['Bolton'], nester_last_names: nil, year: nil, year_ordinal: nil})
    end
    it "should handle a 'de' prefix" do
      expect(@parser.parse('de Andrade, 2001')).to eq({author_last_names: ['de Andrade'], nester_last_names: nil, year: '2001', year_ordinal: nil})
    end
  end

end
