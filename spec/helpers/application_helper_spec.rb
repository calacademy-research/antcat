# This spec used to contain tests for user authorization. The helper methods
# are now creating using `helper_method` in the ApplicationController, and
# I do not know how to test that from here.

require 'spec_helper'

describe ApplicationHelper do

  describe 'Making a link menu' do
    it "should put bars between them and be html safe" do
      result = helper.make_link_menu(['a', 'b'])
      expect(result).to eq('<span>a | b</span>')
    end
    it "should always be html safe" do
      expect(helper.make_link_menu('a'.html_safe, 'b'.html_safe)).to be_html_safe
      expect(helper.make_link_menu(['a'.html_safe, 'b'])).to be_html_safe
    end
  end

  describe "Formatting time ago" do
    it "formats time" do
      time = Time.now - 1.hour
      expect(helper.format_time_ago(time)).to match(%r{<span title=[^>]+>about 1 hour ago</span>})
    end
  end

  describe "Formatting a count with a noun" do
    it "should work" do
      expect(helper.count_and_noun(['1'], 'reference')).to eq('1 reference')
      expect(helper.count_and_noun([], 'reference')).to eq('no references')
    end
  end

  describe "Pluralizing, with commas" do
    it "should handle a single item" do
      expect(helper.pluralize_with_delimiters(1, 'bear')).to eq('1 bear')
    end
    it "should pluralize" do
      expect(helper.pluralize_with_delimiters(2, 'bear')).to eq('2 bears')
    end
    it "should use the provided plural" do
      expect(helper.pluralize_with_delimiters(2, 'genus', 'genera')).to eq('2 genera')
    end
    it "should use commas" do
      expect(helper.pluralize_with_delimiters(2000, 'bear')).to eq('2,000 bears')
    end
  end

  describe "italicization" do
    it "should italicize" do
      string = helper.italicize('Atta')
      expect(string).to eq('<i>Atta</i>')
      expect(string).to be_html_safe
    end
    it "should unitalicize" do
      string = helper.unitalicize('Attini <i>Atta major</i> r.'.html_safe)
      expect(string).to eq('Attini Atta major r.')
      expect(string).to be_html_safe
    end
    it "should two italicizations together" do
      string = helper.unitalicize('Attini <i>Atta</i> <i>major</i> r.'.html_safe)
      expect(string).to eq('Attini Atta major r.')
      expect(string).to be_html_safe
    end
    it "should raise if unitalicize is called on an unsafe string" do
      expect {helper.unitalicize('Attini <i>Atta major</i> r.')}.to raise_error
    end
  end

end
