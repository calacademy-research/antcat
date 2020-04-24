# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::JournalsController, as: :visitor do
  describe "GET index" do
    specify do
      journal = create :journal, name: 'Zootaxa'
      get :index
      expect(json_response).to eq([journal.as_json(root: true)])
    end

    specify { expect(get(:index)).to have_http_status :ok }
  end

  describe "GET show" do
    let!(:journal) { create :journal, name: 'Zootaxa' }

    specify do
      get :show, params: { id: journal.id }
      expect(json_response).to eq(
        {
          "journal" => {
            "id" => journal.id,
            "name" => "Zootaxa",
            "created_at" => journal.created_at.as_json,
            "updated_at" => journal.updated_at.as_json
          }
        }
      )
    end

    specify { expect(get(:show, params: { id: journal.id })).to have_http_status :ok }
  end
end
