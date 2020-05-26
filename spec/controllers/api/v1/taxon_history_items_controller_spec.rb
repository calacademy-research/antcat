# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::TaxonHistoryItemsController, as: :visitor do
  describe "GET index" do
    specify do
      taxon_history_item = create :taxon_history_item

      get :index
      expect(json_response).to eq(
        [
          {
            "taxon_history_item" => {
              "id" => taxon_history_item.id,
              "taxon_id" => taxon_history_item.taxon.id,
              "position" => taxon_history_item.position,
              "taxt" => taxon_history_item.taxt,

              "created_at" => taxon_history_item.created_at.as_json,
              "updated_at" => taxon_history_item.updated_at.as_json
            }
          }
        ]
      )
    end

    specify { expect(get(:index)).to have_http_status :ok }
  end

  describe "GET show" do
    let!(:taxon_history_item) { create :taxon_history_item }

    specify do
      get :show, params: { id: taxon_history_item.id }
      expect(json_response).to eq(
        {
          "taxon_history_item" => {
            "id" => taxon_history_item.id,
            "taxon_id" => taxon_history_item.taxon.id,
            "position" => taxon_history_item.position,
            "taxt" => taxon_history_item.taxt,

            "created_at" => taxon_history_item.created_at.as_json,
            "updated_at" => taxon_history_item.updated_at.as_json
          }
        }
      )
    end

    specify { expect(get(:show, params: { id: taxon_history_item.id })).to have_http_status :ok }
  end
end
