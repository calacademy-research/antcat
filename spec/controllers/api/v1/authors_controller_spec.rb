# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::AuthorsController, as: :visitor do
  describe "GET index" do
    specify do
      author = create :author
      get :index
      expect(json_response).to eq([author.as_json(root: true)])
    end

    specify { expect(get(:index)).to have_http_status :ok }
  end

  describe "GET show" do
    let!(:author) { create :author }

    specify do
      get :show, params: { id: author.id }
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

    specify { expect(get(:show, params: { id: author.id })).to have_http_status :ok }
  end
end
