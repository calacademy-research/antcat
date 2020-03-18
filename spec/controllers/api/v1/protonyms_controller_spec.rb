require 'rails_helper'

describe Api::V1::ProtonymsController do
  describe "GET index" do
    before do
      create :protonym
      get :index
    end

    it "gets all protonyms" do
      expect(json_response.count).to eq 1
    end

    specify { expect(response).to have_http_status :ok }
  end

  describe "GET show" do
    let!(:protonym) { create :protonym, :with_taxts, biogeographic_region: Protonym::NEARCTIC_REGION, locality: "USA" }

    before { get :show, params: { id: protonym.id } }

    specify do
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

    specify { expect(response).to have_http_status :ok }
  end
end
