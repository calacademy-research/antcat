# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::ReferenceAuthorNamesController, as: :visitor do
  describe "GET index" do
    specify do
      create :reference_author_name
      get :index
      expect(json_response).to eq(ReferenceAuthorName.all.as_json(root: true))
    end

    specify { expect(get(:index)).to have_http_status :ok }
  end

  describe "GET show" do
    let!(:reference_author_name) { create :reference_author_name }

    specify do
      get :show, params: { id: reference_author_name.id }
      expect(json_response).to eq(
        {
          "reference_author_name" => {
            "id" => reference_author_name.id,
            "author_name_id" => reference_author_name.author_name.id,
            "reference_id" => reference_author_name.reference.id,
            "position" => reference_author_name.position,

            "created_at" => reference_author_name.created_at.as_json,
            "updated_at" => reference_author_name.updated_at.as_json
          }
        }
      )
    end

    specify { expect(get(:show, params: { id: reference_author_name.id })).to have_http_status :ok }
  end
end
