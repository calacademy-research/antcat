require 'rails_helper'

describe Api::V1::AuthorNamesController do
  describe "GET index" do
    before do
      create :author_name, name: 'Bolton'
      create :author_name, name: 'Fisher'
    end

    it "gets all author names keys" do
      get(:index)

      expect(response.body.to_s).to include "Bolton"
      expect(response.body.to_s).to include "Fisher"
      expect(json_response.count).to eq 2
    end

    specify { expect(get(:index)).to have_http_status :ok }
  end

  describe "GET show" do
    let!(:author_name) { create :author_name, name: 'Bolton' }

    specify do
      get :show, params: { id: author_name.id }
      expect(json_response).to eq(
        {
          "author_name" => {
            "id" => author_name.id,
            "author_id" => author_name.author_id,
            "name" => "Bolton",
            "created_at" => author_name.created_at.as_json,
            "updated_at" => author_name.updated_at.as_json
          }
        }
      )
    end

    specify { expect(get(:show, params: { id: author_name.id })).to have_http_status :ok }
  end
end
