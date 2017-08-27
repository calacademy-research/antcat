require 'spec_helper'

describe Api::V1::TaxonHistoryItemsController do
  before do
    6.times { TaxonHistoryItem.create! taxt: "{ref 999" }
  end

  describe "GET index" do
    it "gets all taxon history items greater than a given number" do
      # Get index starting at four
      get :index, starts_at: 4
      expect(response.status).to eq 200

      taxon_history_item = JSON.parse response.body
      # since we want no ids less than 4, we should get a starting id at 4
      expect(taxon_history_item[0]['taxon_history_item']['id']).to eq 4
      expect(taxon_history_item.count).to eq 3
    end

    it "gets all taxon_history_items" do
      get :index
      expect(response.status).to eq 200
      expect(response.body.to_s).to include "position"

      taxon_history_items = JSON.parse response.body
      expect(taxon_history_items.count).to eq 6
    end
  end
end
