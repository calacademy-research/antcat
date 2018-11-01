require 'spec_helper'

describe ApplicationHelper do
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
        results = helper.italicize 'Atta'
        expect(results).to eq '<i>Atta</i>'
        expect(results).to be_html_safe
      end
    end

    describe "#unitalicize" do
      it "removes <i> tags" do
        results = helper.unitalicize('Attini <i>Atta major</i> r.'.html_safe)
        expect(results).to eq 'Attini Atta major r.'
        expect(results).to be_html_safe
      end

      it "handles multiple <i> tags" do
        results = helper.unitalicize('Attini <i>Atta</i> <i>major</i> r.'.html_safe)
        expect(results).to eq 'Attini Atta major r.'
        expect(results).to be_html_safe
      end

      it "raises if called on unsafe strings" do
        expect { helper.unitalicize('Attini <i>Atta major</i> r.') }.
          to raise_error("Can't unitalicize an unsafe string")
      end
    end
  end

  describe "#antcat_icon" do
    it "formats" do
      expect(helper.antcat_icon).to eq '<span class="antcat_icon"></span>'
    end

    describe "arguments" do
      context "when a string" do
        specify { expect(icon_classes("issue")).to eq "antcat_icon issue" }
      end

      context "when two strings" do
        specify { expect(icon_classes("issue open")).to eq "antcat_icon issue open" }
      end

      context "when array" do
        specify { expect(icon_classes(["issue open"])).to eq "antcat_icon issue open" }
      end
    end

    def icon_classes *css_classes
      extract_css_classes helper.antcat_icon(*css_classes)
    end

    def extract_css_classes string
      string.scan(/class="(.*?)"/).first.first
    end
  end
end
