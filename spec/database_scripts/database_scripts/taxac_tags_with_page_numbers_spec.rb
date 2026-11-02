# frozen_string_literal: true

require 'rails_helper'

describe DatabaseScripts::TaxacTagsWithPageNumbers do
  describe "#results" do
    let(:taxon) { create :species }

    it "finds a taxac tag followed by a page number (the query runs on MySQL 8)" do
      item = create :history_item, :taxt, taxt: "Senior synonym of {taxac #{taxon.id}}: 12"
      create :history_item, :taxt, taxt: "Senior synonym of {taxac #{taxon.id}}."

      expect(described_class.new.results).to eq [item]
    end
  end
end
