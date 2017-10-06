require 'spec_helper'

describe Api::V1::TaxonHistoryItemsController do
  before { 6.times { TaxonHistoryItem.create! taxt: "{ref 999" } }

  describe "GET index" do
    # TODO depends on being run before any other specs.
    xit "gets all taxon history items greater than a given number" do
      get :index, starts_at: 4 # Get index starting at four.

      # Since we want no ids less than 4, we should get a starting id at 4.
      taxon_history_item = JSON.parse response.body
      expect(taxon_history_item[0]['taxon_history_item']['id']).to eq 4
      expect(taxon_history_item.count).to eq 3
    end

    it "gets all taxon_history_items" do
      get :index

      expect(response.body.to_s).to include "position"
      taxon_history_items = JSON.parse response.body
      expect(taxon_history_items.count).to eq 6
    end

    it 'returns HTTP 200' do
      get :index
      expect(response).to have_http_status 200
    end
  end
end
