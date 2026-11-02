# frozen_string_literal: true

require 'rails_helper'

describe DatabaseScripts::NonStandardReplacementNameHistoryItems do
  describe "#results" do
    let(:taxon) { create :species }
    let(:reference) { create :any_reference }

    it "leaves out standard items and finds the others (the query runs on MySQL 8)" do
      create :history_item, :taxt, taxt: "Replacement name: {taxac #{taxon.id}}."
      create :history_item, :taxt, taxt: "Replacement name: {taxac #{taxon.id}} ({ref #{reference.id}}: 5)."
      odd = create :history_item, :taxt, taxt: "Replacement name: Lasius niger."

      expect(described_class.new.results).to eq [odd]
    end
  end
end
