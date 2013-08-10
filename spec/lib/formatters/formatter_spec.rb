# coding: UTF-8
require 'spec_helper'

describe Formatters::Formatter do
  before do
    @formatter = Formatters::Formatter
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
      result = @formatter.conjuncted_list(['a', 'b'], 'item')
      result.should == %{<span class="item">a</span> and <span class="item">b</span>}
      result.should be_html_safe
    end
    it "should handle four items" do
      @formatter.conjuncted_list(['a', 'b', 'c', 'd'], 'item').should ==
        %{<span class="item">a</span>, <span class="item">b</span>, <span class="item">c</span> and <span class="item">d</span>}
    end
    it "should escape the items" do
      @formatter.conjuncted_list(['<script>'], 'item').should == %{<span class="item">&lt;script&gt;</span>}
    end
  end

  describe "Pluralizing, with commas" do
    it "should pluralize" do
      @formatter.pluralize_with_delimiters(2, 'bear').should == '2 bears'
    end
    it "should use the provided plural" do
      @formatter.pluralize_with_delimiters(2, 'genus', 'genera').should == '2 genera'
    end
    it "should use commas" do
      @formatter.pluralize_with_delimiters(2000, 'bear').should == '2,000 bears'
    end
  end

  describe "italicization" do
    it "should italicize" do
      string = @formatter.italicize('Atta')
      string.should == '<i>Atta</i>'
      string.should be_html_safe
    end
    it "should unitalicize" do
      string = @formatter.unitalicize('Attini <i>Atta major</i> r.'.html_safe)
      string.should == 'Attini Atta major r.'
      string.should be_html_safe
    end
    it "should raise if unitalicize is called on an unsafe string" do
      -> {@formatter.unitalicize('Attini <i>Atta major</i> r.')}.should raise_error
    end
  end

  describe "bold" do
    it "should bold" do
      string = @formatter.embolden('Atta')
      string.should == '<b>Atta</b>'
      string.should be_html_safe
    end
  end

end
