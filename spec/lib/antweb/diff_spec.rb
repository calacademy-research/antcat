require 'spec_helper'

describe Antweb::Diff do
  before do
    @diff = Antweb::Diff.new
  end

  it "should consider two equal arrays as equal" do
    @diff.diff(['1','2','3'], ['1','2','3'])
    @diff.match_count.should == 3
  end

  it "should count completely different arrays as different" do
    @diff.diff(['1','2','3'], ['4','5','6'])
    @diff.match_count.should == 0
  end

  it "should detect one match" do
    @diff.diff(['1','2','3'], ['4','1','6'])
    @diff.match_count.should == 1
  end

  it "should report the number of lines on each side that were different" do
    @diff.diff ["a\tb\tc\td\te"], ["a\tb\tc\td\tf"]
    @diff.difference_count.should == 1
  end

  it "should report the number of lines on each side that weren't matched" do
    @diff.diff ["a\t1\t2\t3\tb", "b\tc", "antcat"], ["a\t1\t2\t3\tc", "b\tc", "antweb-1", "antweb-2"]
    @diff.antcat_unmatched_count.should == 1
    @diff.antweb_unmatched_count.should == 2
  end

  it "should not care about the case of TRUE and FALSE" do
    @diff.diff ["a\t1\t2\t3\tTRUE\tFALSE"], ["a\t1\t2\t3\ttrue\tfalse"] 
    @diff.match_count.should == 1
  end

  it "should consider it a 'match with a difference' if the first four columns match, but the rest doesn't" do
    @diff.diff ["1\t2\t3\t4\ta"], ["1\t2\t3\t4\tb"]
    @diff.antcat_unmatched_count.should == 0
    @diff.antweb_unmatched_count.should == 0
    @diff.difference_count.should == 1
  end

  it "should find the best match out of the lines with the same prefix" do
    antcat = ["1\t2\t3\t4D"]
    antweb = ["1\t2\t3\t4A", "1\t2\t3\t4D"]
    @diff.diff antweb, antcat
    @diff.match_count.should == 1
    @diff.antcat_unmatched_count.should == 0
    @diff.antweb_unmatched_count.should == 1
  end

  describe "showing where two strings differ" do

    it "should return nil if they're equal" do
      Antweb::Diff.match_fails_at('abc', 'abc').should == nil
    end

    it "should return 0 if they differ at the first character" do
      Antweb::Diff.match_fails_at('a', 'b').should == 0
    end

    it "should return the size of the shorter string if it's a substring of the other" do
      Antweb::Diff.match_fails_at('ab', 'a').should == 1
    end
  
  end

end
