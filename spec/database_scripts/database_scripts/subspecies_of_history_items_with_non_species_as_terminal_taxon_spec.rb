# frozen_string_literal: true

require 'rails_helper'

describe DatabaseScripts::SubspeciesOfHistoryItemsWithNonSpeciesAsTerminalTaxon do
  let(:script) { described_class.new }

  context "with results" do
    let!(:subspecies) { create :subspecies }
    let!(:history_item) { create :history_item, :subspecies_of, object_protonym: subspecies.protonym }

    specify { expect(script.results).to eq [history_item] }

    it_behaves_like "a database script with renderable results"
  end

  context "without results" do
    let!(:species) { create :species }
    let!(:history_item) { create :history_item, :subspecies_of, object_protonym: species.protonym }

    specify { expect(script.results).to eq [] }
  end
end
