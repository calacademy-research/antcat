# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::AuthorNamesController, as: :visitor do
  describe "GET index" do
    specify do
      author_name = create :author_name, name: 'Fisher'
      get :index
      expect(json_response).to eq([author_name.as_json])
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
