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

  it "should report the number of lines on each side that weren't matched" do
    @diff.diff ["a\tb", "b\tc"], ["a\tc", "b\tc"]
    @diff.difference_count.should == 1
  end
end
