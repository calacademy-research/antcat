# frozen_string_literal: true

require 'rails_helper'

describe ApplicationHelper do
  describe "#or_dash" do
    specify do
      expect(helper.or_dash('')).to eq "–"
      expect(helper.or_dash(nil)).to eq "–"
      expect(helper.or_dash(0)).to eq "–"
      expect(helper.or_dash(Taxon)).to eq Taxon
    end
  end

  describe "#foundation_class_for" do
    specify { expect(helper.foundation_class_for("notice")).to eq "primary" }
    specify { expect(helper.foundation_class_for("alert")).to eq "alert" }
    specify { expect(helper.foundation_class_for("error")).to eq "alert" }
  end
end
