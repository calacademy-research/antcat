# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::ProtonymsController, as: :visitor do
  describe "GET index" do
    specify do
      protonym = create :protonym
      get :index
      expect(json_response).to eq([protonym.as_json])
    end

    specify { expect(get(:index)).to have_http_status :ok }
  end

  describe "GET show" do
    let!(:protonym) { create :protonym, :with_taxts, biogeographic_region: Protonym::NEARCTIC_REGION, locality: "USA" }

    specify do
      get :show, params: { id: protonym.id }
      expect(json_response).to eq(
        {
          "protonym" => {
            "id" => protonym.id,
            "name_id" => protonym.name_id,
            "authorship_id" => protonym.authorship.id,
            "sic" => protonym.sic,
            "fossil" => protonym.fossil,
            "biogeographic_region" => Protonym::NEARCTIC_REGION,
            "locality" => 'USA',
            "primary_type_information_taxt" => protonym.primary_type_information_taxt,
            "secondary_type_information_taxt" => protonym.secondary_type_information_taxt,
            "type_notes_taxt" => protonym.type_notes_taxt,
            "created_at" => protonym.created_at.as_json,
            "updated_at" => protonym.updated_at.as_json
          }
        }
      )
    end

    specify { expect(get(:show, params: { id: protonym.id })).to have_http_status :ok }
  end
end
