# This spec used to contain tests for user authorization. The helper methods
# are now creating using `helper_method` in the ApplicationController, and
# I do not know how to test that from here.

require 'spec_helper'

describe ApplicationHelper do
  describe '#make_link_menu' do
    it "puts bars between the items and is html safe" do
      result = helper.make_link_menu ['a', 'b']
      expect(result).to eq '<span>a | b</span>'
    end

    it "should always be html safe" do
      expect(helper.make_link_menu('a'.html_safe, 'b'.html_safe)).to be_html_safe
      expect(helper.make_link_menu(['a'.html_safe, 'b'])).to be_html_safe
    end
  end

  describe "#count_and_noun" do
    it "formats a count with a noun" do
      expect(helper.count_and_noun(['1'], 'reference')).to eq '1 reference'
      expect(helper.count_and_noun([], 'reference')).to eq 'no references'
    end
  end

  # Pluralizing, with commas
  describe "#pluralize_with_delimiters" do
    it "handles single items" do
      expect(helper.pluralize_with_delimiters(1, 'bear')).to eq '1 bear'
    end

    it "pluralizes" do
      expect(helper.pluralize_with_delimiters(2, 'bear')).to eq '2 bears'
    end

    it "uses the provided plural" do
      expect(helper.pluralize_with_delimiters(2, 'genus', 'genera')).to eq '2 genera'
    end

    it "uses commas" do
      expect(helper.pluralize_with_delimiters(2000, 'bear')).to eq '2,000 bears'
    end
  end

  describe "italicization" do
    describe "#italicize" do
      it "adds <i> tags" do
        string = helper.italicize 'Atta'
        expect(string).to eq '<i>Atta</i>'
        expect(string).to be_html_safe
      end
    end

    describe "#unitalicize" do
      it "removes <i> tags" do
        string = helper.unitalicize('Attini <i>Atta major</i> r.'.html_safe)
        expect(string).to eq 'Attini Atta major r.'
        expect(string).to be_html_safe
      end

      it "handles multiple <i> tags" do
        string = helper.unitalicize('Attini <i>Atta</i> <i>major</i> r.'.html_safe)
        expect(string).to eq 'Attini Atta major r.'
        expect(string).to be_html_safe
      end

      it "raises if called on unsafe strings" do
        expect { helper.unitalicize('Attini <i>Atta major</i> r.') }.to raise_error
      end
    end
  end

  describe "#antcat_icon" do
    it "formats" do
      expect(helper.send :antcat_icon).to eq '<span class="antcat_icon"></span>'
    end

    describe "arguments" do
      it "handles a single string" do
        expect(icon_classes "task").to eq "antcat_icon task"
      end

      it "handles two strings" do
        expect(icon_classes "task open").to eq "antcat_icon task open"
      end

      it "handles arrays" do
        expect(icon_classes ["task open"]).to eq "antcat_icon task open"
      end
    end

    def icon_classes *css_classes
      extract_css_classes helper.send(:antcat_icon, *css_classes)
    end

    def extract_css_classes string
      string.scan(/class="(.*?)"/).first.first
    end
  end
end
