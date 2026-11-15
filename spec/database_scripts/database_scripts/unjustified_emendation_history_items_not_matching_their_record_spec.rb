# frozen_string_literal: true

require 'rails_helper'

describe DatabaseScripts::UnjustifiedEmendationHistoryItemsNotMatchingTheirRecord do
  subject(:database_script) { described_class.new }

  let!(:history_item) { create :history_item, :unjustified_emendation }
  let(:record) { history_item.object_taxon }

  describe "#results" do
    it 'returns nothing while the item matches its record' do
      expect(database_script.results).to eq []
    end

    it "returns an item whose record's status changed" do
      record.update_columns(status: Status::SYNONYM)
      expect(database_script.results).to eq [history_item]
    end

    it "returns an item whose record's current taxon moved to another protonym" do
      record.update_columns(current_taxon_id: create(:genus).id)
      expect(database_script.results).to eq [history_item]
    end

    it "returns an item whose spelling is not the record's" do
      history_item.update_columns(text_value: '<i>otherspelling</i>')
      expect(database_script.results).to eq [history_item]
    end

    it "returns an item whose spelling differs from the record's only in case" do
      history_item.update_columns(text_value: record.name.epithet.upcase)
      expect(database_script.results).to eq [history_item]
    end

    it 'returns an item that lost its record (a foreign key keeps the record from being deleted)' do
      history_item.update_columns(object_taxon_id: nil)
      expect(database_script.results).to eq [history_item]
      expect(DatabaseScripts::Render.new(database_script, {}).call).to include 'no linked record'
    end

    it 'ignores justified emendations' do
      create :history_item, :emendation
      expect(database_script.results).to eq []
    end
  end

  context 'with results' do
    let(:script) { database_script }

    before { record.update_columns(status: Status::SYNONYM) }

    it 'names the problem' do
      expect(DatabaseScripts::Render.new(database_script, {}).call).to include 'status is synonym'
    end

    it_behaves_like "a database script with renderable results"
  end
end
