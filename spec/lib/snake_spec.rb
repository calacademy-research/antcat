require 'spec_helper'

require 'snake'

describe "array snaking" do
  it "should handle []" do
    [].snake(1).should == []
  end
  it "should handle [1]" do
    [1].snake(1).should == [[1]]
  end

  it "should handle [1,2,3,4]" do
    [1,2,3,4].snake(2).should == [[1,3], [2,4]]
  end

  it "should handle empty cells" do
    [1,2,3,4,5].snake(2).should == [[1,4], [2,5], [3,nil]]
  end
end
