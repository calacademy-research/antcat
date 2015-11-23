# coding: UTF-8
require 'spec_helper'

class FormattersFormatterTestClass
  include Formatters::Formatter
end

describe Formatters::Formatter do
  before do
    @formatter = FormattersFormatterTestClass.new
  end

  describe "Formatting a count with a noun" do
    it "should work" do
      expect(@formatter.count_and_noun(['1'], 'reference')).to eq('1 reference')
      expect(@formatter.count_and_noun([], 'reference')).to eq('no references')
    end
  end

  describe "Formatting a list, with conjunction" do
    it "should handle two items" do
      result = @formatter.conjuncted_list(['a', 'b'], 'item')
      expect(result).to eq(%{<span class="item">a</span> and <span class="item">b</span>})
      expect(result).to be_html_safe
    end
    it "should handle four items" do
      expect(@formatter.conjuncted_list(['a', 'b', 'c', 'd'], 'item')).to eq(
        %{<span class="item">a</span>, <span class="item">b</span>, <span class="item">c</span> and <span class="item">d</span>}
      )
    end
    it "should escape the items" do
      expect(@formatter.conjuncted_list(['<script>'], 'item')).to eq(%{<span class="item">&lt;script&gt;</span>})
    end
  end

  describe "Pluralizing, with commas" do
    it "should handle a single item" do
      expect(@formatter.pluralize_with_delimiters(1, 'bear')).to eq('1 bear')
    end
    it "should pluralize" do
      expect(@formatter.pluralize_with_delimiters(2, 'bear')).to eq('2 bears')
    end
    it "should use the provided plural" do
      expect(@formatter.pluralize_with_delimiters(2, 'genus', 'genera')).to eq('2 genera')
    end
    it "should use commas" do
      expect(@formatter.pluralize_with_delimiters(2000, 'bear')).to eq('2,000 bears')
    end
  end

  describe "italicization" do
    it "should italicize" do
      string = @formatter.italicize('Atta')
      expect(string).to eq('<i>Atta</i>')
      expect(string).to be_html_safe
    end
    it "should unitalicize" do
      string = @formatter.unitalicize('Attini <i>Atta major</i> r.'.html_safe)
      expect(string).to eq('Attini Atta major r.')
      expect(string).to be_html_safe
    end
    it "should two italicizations together" do
      string = @formatter.unitalicize('Attini <i>Atta</i> <i>major</i> r.'.html_safe)
      expect(string).to eq('Attini Atta major r.')
      expect(string).to be_html_safe
    end
    it "should raise if unitalicize is called on an unsafe string" do
      expect {@formatter.unitalicize('Attini <i>Atta major</i> r.')}.to raise_error
    end
  end

  describe "bold" do
    it "should bold" do
      string = @formatter.embolden('Atta')
      expect(string).to eq('<b>Atta</b>')
      expect(string).to be_html_safe
    end
  end

  describe "Converting a hash to a parameter string" do
    it "should work" do
      expect(@formatter.hash_to_params_string(a: 'b', c: 'd')).to eq('a=b&c=d')
    end
  end

  describe "Formatting an email address + name" do
    it "should format it correctly in the general case" do
      string = @formatter.format_name_linking_to_email 'Stan Blum', 'sblum@example.com'
      expect(string).to eq('<a href="mailto:sblum@example.com">Stan Blum</a>')
    end
    it "should format it correctly for 'doers'" do
      user = FactoryGirl.create :user, name: 'Stan Blum', email: 'sblum@example.com'
      string = @formatter.format_doer_name user
      expect(string).to eq('<a href="mailto:sblum@example.com">Stan Blum</a>')
    end
    it "should format it correctly when the 'doer' is nil" do
      string = @formatter.format_doer_name nil
      expect(string).to eq('Someone')
    end
  end

end
