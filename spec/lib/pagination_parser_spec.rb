require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

require 'citrus/debug'

describe PaginationParser do

  describe "parsing pagination" do
    it "should return an empty string if the string is empty" do
      ['', nil].each do |string|
        PaginationParser.parse(string).should == ''
      end
    end

    it "should parse a simple page count" do
      string = '5 pp.'
      PaginationParser.parse(string).should == '5 pp.'
      string.should == ''
    end

    it "should parse a range of pages" do
      string = '5-6 pp.'
      PaginationParser.parse(string).should == '5-6 pp.'
      string.should == ''
    end

    it "should parse roman numerals" do
      string = 'i-ix pp.'
      PaginationParser.parse(string).should == 'i-ix pp.'
      string.should == ''
    end

    ['pp', 'pp.', 'pps', 'pps.',
     'p', 'p.', 'ps', 'ps.',
     'pl', 'pl.', 'pls', 'pls.',
     'map', 'maps'].each do |type|
      it "should handle the '#{type}' section type" do
        PaginationParser.parse("2 #{type}").should be_present
      end
    end

    it "should handle a section size alone" do
      string = '1'
      PaginationParser.parse(string).should == '1'
      string.should == ''
    end

    it "should handle brackets around a section size" do
      string = '[1-6] pp.'
      PaginationParser.parse(string).should == '[1-6] pp.'
      string.should == ''
    end

    it "should handle having the section type first" do
      string = 'p. 345.'
      PaginationParser.parse(string).should == 'p. 345.'
      string.should == ''
    end

    it "should handle having a note in front of a size-type clause" do
      string = '(note) 345 pp.'
      PaginationParser.parse(string).should == '(note) 345 pp.'
      string.should == ''
    end

    it "should handle having a note after a size-type clause" do
      string = '345 pp. (note)'
      PaginationParser.parse(string).should == '345 pp. (note)'
      string.should == ''
    end

    it "should handle having a note after a size-type clause followed by a period" do
      string = '345 pp. (note).'
      PaginationParser.parse(string).should == '345 pp. (note).'
      string.should == ''
    end

    it "should handle having a notes in brackets" do
      string = '[note] 345 pp. [another note]'
      PaginationParser.parse(string).should == '[note] 345 pp. [another note]'
      string.should == ''
    end

    it "should handle multiple pagination clauses" do
      string = '[6] + 143-587 pp.'
      PaginationParser.parse(string).should == '[6] + 143-587 pp.'
      string.should == ''
    end

    it "should handle multiple pagination clauses without even a plus sign" do
      string = '[6] 143-587 pp.'
      PaginationParser.parse(string).should == '[6] 143-587 pp.'
      string.should == ''
    end

    it "should handle three pagination clauses" do
      string = 'xxxiv + 416 + 388 pp.'
      PaginationParser.parse(string).should == 'xxxiv + 416 + 388 pp.'
      string.should == ''
    end

    it "should handle pagination clauses separated by commas" do
      string = 'xxxiv, 416 + 388 pp.'
      PaginationParser.parse(string).should == 'xxxiv, 416 + 388 pp.'
      string.should == ''
    end

    ['1 p., 5 maps',
      '12 + 532 pp.',
      '24 pp. 24 pls.',
      '247 pp. + 14 pl. + 4 pp. (index)',
      '312 + (posthumous section) 95 pp.',
      '5-187 + i-viii pp.',
      '5 maps',
      '8 pls., 84 pp.',
      'i-ii, 279-655',
      'xi',
      '93-114, 121'
    ].each do |pagination|
      it "should handle '#{pagination}'" do
        expected = pagination.dup
        PaginationParser.parse(pagination).should == expected
        pagination.should == ''
      end
    end
  end

end
