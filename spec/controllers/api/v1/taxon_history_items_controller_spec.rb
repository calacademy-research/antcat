# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::TaxonHistoryItemsController, as: :visitor do
  describe "GET index" do
    specify do
      history_item = create :history_item

      get :index
      expect(json_response).to eq(
        [
          {
            "history_item" => {
              "id" => history_item.id,
              "protonym_id" => history_item.protonym.id,
              "position" => history_item.position,
              "taxt" => history_item.taxt,

              "created_at" => history_item.created_at.as_json,
              "updated_at" => history_item.updated_at.as_json
            }
          }
        ]
      )
    end

    specify { expect(get(:index)).to have_http_status :ok }
  end

  describe "GET show" do
    let!(:history_item) { create :history_item }

    specify do
      get :show, params: { id: history_item.id }
      expect(json_response).to eq(
        {
          "history_item" => {
            "id" => history_item.id,
            "protonym_id" => history_item.protonym.id,
            "position" => history_item.position,
            "taxt" => history_item.taxt,

            "created_at" => history_item.created_at.as_json,
            "updated_at" => history_item.updated_at.as_json
          }
        }
      )
    end

    specify { expect(get(:show, params: { id: history_item.id })).to have_http_status :ok }
  end
end
