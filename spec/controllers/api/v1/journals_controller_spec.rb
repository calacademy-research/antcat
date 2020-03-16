require 'rails_helper'

describe Api::V1::JournalsController do
  describe "GET show" do
    let!(:journal) { create :journal, name: 'Zootaxa' }

    before { get :show, params: { id: journal.id } }

    specify do
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

    specify { expect(response).to have_http_status :ok }
  end
end
