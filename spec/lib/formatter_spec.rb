# coding: UTF-8
require 'spec_helper'

describe Formatter do
  before do
    @formatter = Formatter
  end

  describe "Formatting a list, with conjunction" do
    it "should handle two items" do
      @formatter.format_conjuncted_list(['a', 'b'], 'item').should ==
        %{<span class="item">a</span> and <span class="item">b</span>}
    end
    it "should handle four items" do
      @formatter.format_conjuncted_list(['a', 'b', 'c', 'd'], 'item').should ==
        %{<span class="item">a</span>, <span class="item">b</span>, <span class="item">c</span> and <span class="item">d</span>}
    end
  end
end
