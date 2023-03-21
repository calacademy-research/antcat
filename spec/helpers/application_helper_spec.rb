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

  describe "#flash_message_class" do
    specify { expect(helper.flash_message_class("notice")).to eq "callout-blue" }
    specify { expect(helper.flash_message_class("alert")).to eq "callout-danger" }
    specify { expect(helper.flash_message_class("error")).to eq "callout-danger" }
  end
end
