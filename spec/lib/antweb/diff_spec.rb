require 'spec_helper'

describe Antweb::Diff do
  before do
    @diff = Antweb::Diff.new
  end

  it "should consider two equal arrays as equal" do
    @diff.diff(['1','2','3'], ['1','2','3'])
    @diff.left_count.should == 3
    @diff.right_count.should == 3
    @diff.match_count.should == 3
  end

  it "should count the elements in each array" do
    @diff.diff(['1','2','3'], ['1','2'])
    @diff.left_count.should == 3
    @diff.right_count.should == 2
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
    @diff.diff ["a\tb", "b\tc"], ["a\tc", "b\tc"]
    @diff.difference_count.should == 1
  end

  it "should report the number of lines on each side that weren't matched" do
    @diff.diff ["a\tb", "b\tc", "left"], ["a\tc", "b\tc", "right-1", "right-2"]
    @diff.left_unmatched_count.should == 1
    @diff.right_unmatched_count.should == 2
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
  
    it "should insert a pointer to the failure" do
      Antweb::Diff.format_failed_match('abc', 0).should == 'a<<<bc'
    end

    it "should insert a pointer to the failure when it's at the end of one of the strings" do
      Antweb::Diff.format_failed_match('abc', 3).should == 'abc[substring]'
    end

  end

end
