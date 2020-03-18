require 'rails_helper'

describe Api::V1::AuthorsController do
  describe "GET index" do
    let!(:author) { create :author }
    let!(:another_author) { create :author }

    before { get :index }

    it "gets all author primary keys" do
      expect(response.body.to_s).to include author.id.to_s
      expect(response.body.to_s).to include another_author.id.to_s
      expect(json_response.count).to eq 2
    end

    specify { expect(response).to have_http_status :ok }
  end

  describe "GET show" do
    let!(:author) { create :author }

    before { get :show, params: { id: author.id } }

    specify do
      expect(json_response).to eq(
        {
          "author" => {
            "id" => author.id,
            "created_at" => author.created_at.as_json,
            "updated_at" => author.updated_at.as_json
          }
        }
      )
    end

    specify { expect(response).to have_http_status :ok }
  end
end
