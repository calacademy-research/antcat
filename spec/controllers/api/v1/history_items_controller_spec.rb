# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::HistoryItemsController, as: :visitor do
  def expected_json history_item
    {
      "id" => history_item.id,
      "protonym_id" => history_item.protonym.id,
      "position" => history_item.position,
      "taxt" => history_item.taxt,

      "type" => history_item.type,
      "subtype" => history_item.subtype,
      "rank" => history_item.rank,
      "picked_value" => history_item.picked_value,
      "text_value" => history_item.text_value,
      "reference_id" => history_item.reference_id,
      "pages" => history_item.pages,
      "object_protonym_id" => history_item.object_protonym_id,
      "object_taxon_id" => history_item.object_taxon_id,
      "force_author_citation" => history_item.force_author_citation,

      "created_at" => history_item.created_at.as_json,
      "updated_at" => history_item.updated_at.as_json
    }
  end

  describe "GET index" do
    specify do
      history_item = create :history_item, :taxt

      get :index
      expect(json_response).to eq([{ "history_item" => expected_json(history_item) }])
    end

    specify { expect(get(:index)).to have_http_status :ok }
  end

  describe "GET show" do
    let!(:history_item) { create :history_item, :taxt }

    specify do
      get :show, params: { id: history_item.id }
      expect(json_response).to eq({ "history_item" => expected_json(history_item) })
    end

    specify { expect(get(:show, params: { id: history_item.id })).to have_http_status :ok }

    context "with a relational history item" do
      let!(:history_item) { create :history_item, :junior_synonym_of, :force_author_citation }

      it "includes the fields of relational history items" do
        get :show, params: { id: history_item.id }

        item = json_response["history_item"]
        expect(item).to eq(expected_json(history_item))
        expect(item["type"]).to eq History::Definitions::JUNIOR_SYNONYM_OF
        expect(item["reference_id"]).to eq history_item.reference.id
        expect(item["pages"]).to eq history_item.pages
        expect(item["object_protonym_id"]).to eq history_item.object_protonym.id
        expect(item["object_taxon_id"]).to be_nil
        expect(item["force_author_citation"]).to be true
      end
    end

    context "with a type specimen designation" do
      let!(:history_item) { create :history_item, :lectotype_designation }

      it "includes the subtype" do
        get :show, params: { id: history_item.id }

        expect(json_response["history_item"]["subtype"]).to eq History::Definitions::LECTOTYPE_DESIGNATION
      end
    end
  end
end
