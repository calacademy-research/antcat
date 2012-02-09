# coding: UTF-8
require 'spec_helper'

describe Formatter do
  before do
    @formatter = CatalogFormatter
  end

  describe "Pluralizing with commas" do
    it "should handle a single item" do
      @formatter.pluralize_with_delimiters(1, 'bear').should == '1 bear'
    end
  end

  describe "Formatting a count with a noun" do
    it "should work" do
      @formatter.count_and_noun(['1'], 'reference').should == '1 reference'
      @formatter.count_and_noun([], 'reference').should == 'no references'
    end
  end

  describe "Formatting a list, with conjunction" do
    it "should handle two items" do
      @formatter.pluralize_with_delimiters(2, 'bear').should == '2 bears'
      @formatter.conjuncted_list(['a', 'b'], 'item').should ==
        %{<span class="item">a</span> and <span class="item">b</span>}
    end
    it "should use the provided plural" do
      @formatter.pluralize_with_delimiters(2, 'genus', 'genera').should == '2 genera'
    end
    it "should handle four items" do
      @formatter.conjuncted_list(['a', 'b', 'c', 'd'], 'item').should ==
        %{<span class="item">a</span>, <span class="item">b</span>, <span class="item">c</span> and <span class="item">d</span>}
    end
    it "should use commas" do
      @formatter.pluralize_with_delimiters(2000, 'bear').should == '2,000 bears'
    end
  end

end
