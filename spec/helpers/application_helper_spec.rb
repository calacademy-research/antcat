# frozen_string_literal: true

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

  describe "#foundation_class_for" do
    specify { expect(helper.foundation_class_for("notice")).to eq "primary" }
    specify { expect(helper.foundation_class_for("alert")).to eq "alert" }
    specify { expect(helper.foundation_class_for("error")).to eq "alert" }

    context "when `flash_type` is not supported" do
      specify { expect { helper.foundation_class_for("pizza") }.to raise_error(StandardError) }
    end
  end

  describe "#antcat_icon" do
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
