require 'rails_helper'

describe ApplicationHelper do
  describe "#or_dash" do
    specify do
      expect(helper.or_dash('')).to eq "&ndash;"
      expect(helper.or_dash(nil)).to eq "&ndash;"
      expect(helper.or_dash(0)).to eq "&ndash;"
      expect(helper.or_dash(Taxon)).to eq Taxon
    end
  end

  describe "#add_period_if_necessary" do
    specify { expect(helper.add_period_if_necessary('Hi')).to eq 'Hi.' }
    specify { expect(helper.add_period_if_necessary('Hi.')).to eq 'Hi.' }
    specify { expect(helper.add_period_if_necessary('Hi!')).to eq 'Hi!' }
    specify { expect(helper.add_period_if_necessary('Hi?')).to eq 'Hi?' }
    specify { expect(helper.add_period_if_necessary('')).to eq '' }
    specify { expect(helper.add_period_if_necessary(nil)).to eq '' }
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

  describe "#foundation_class_for" do
    specify { expect(helper.foundation_class_for("notice")).to eq "primary" }
    specify { expect(helper.foundation_class_for("alert")).to eq "alert" }
    specify { expect(helper.foundation_class_for("error")).to eq "alert" }

    context "when `flash_type` is not supported" do
      specify { expect { helper.foundation_class_for("pizza") }.to raise_error(StandardError) }
    end
  end

  describe "#antcat_icon" do
    specify { expect(helper.antcat_icon).to eq '<span class="antcat_icon"></span>' }

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
