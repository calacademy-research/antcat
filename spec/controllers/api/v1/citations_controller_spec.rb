# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::CitationsController, as: :visitor do
  describe "GET index" do
    specify do
      citation = create :citation

      get :index
      expect(json_response).to eq(
        [
          {
            "citation" => {
              "id" => citation.id,
              "pages" => citation.pages,
              "reference_id" => citation.reference.id,

              "created_at" => citation.created_at.as_json,
              "updated_at" => citation.updated_at.as_json
            }
          }
        ]
      )
    end

    specify { expect(get(:index)).to have_http_status :ok }
  end

  describe "GET show" do
    let!(:citation) { create :citation }

    specify do
      get :show, params: { id: citation.id }
      expect(json_response).to eq(
        {
          "citation" => {
            "id" => citation.id,
            "pages" => citation.pages,
            "reference_id" => citation.reference.id,

            "created_at" => citation.created_at.as_json,
            "updated_at" => citation.updated_at.as_json
          }
        }
      )
    end

    specify { expect(get(:show, params: { id: citation.id })).to have_http_status :ok }
  end
end
