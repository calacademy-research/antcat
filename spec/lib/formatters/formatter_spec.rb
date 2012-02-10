# coding: UTF-8
require 'spec_helper'

describe Formatters::Formatter do
  before do
    @formatter = Formatters::Formatter
  end

  describe "Formatting a count with a noun" do
    it "should work" do
      @formatter.count_and_noun(['1'], 'reference').should == '1 reference'
      @formatter.count_and_noun([], 'reference').should == 'no references'
    end
  end
  describe "Formatting a list, with conjunction" do
    it "should handle two items" do
      @formatter.conjuncted_list(['a', 'b'], 'item').should ==
        %{<span class="item">a</span> and <span class="item">b</span>}
    end
    it "should handle four items" do
      @formatter.conjuncted_list(['a', 'b', 'c', 'd'], 'item').should ==
        %{<span class="item">a</span>, <span class="item">b</span>, <span class="item">c</span> and <span class="item">d</span>}
    end
  end
end
