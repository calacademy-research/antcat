require 'spec_helper'

describe Api::V1::TaxonHistoryItemsController do
  before { 2.times { create :taxon_history_item } }

  describe "GET index" do
    it "gets all taxon_history_items" do
      get :index

      expect(response.body.to_s).to include "position"
      expect(json_response.count).to eq 2
    end

    it 'returns HTTP 200' do
      get :index
      expect(response).to have_http_status :ok
    end
  end
end
