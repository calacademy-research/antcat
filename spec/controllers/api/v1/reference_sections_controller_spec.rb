require 'rails_helper'

describe Api::V1::ReferenceSectionsController, as: :visitor do
  describe "GET index" do
    specify do
      reference_section = create :reference_section
      get :index
      expect(json_response).to eq([reference_section.as_json])
    end

    specify { expect(get(:index)).to have_http_status :ok }
  end

  describe "GET show" do
    let!(:reference_section) { create :reference_section, :with_all_taxts }

    specify do
      get :show, params: { id: reference_section.id }
      expect(json_response).to eq(
        {
          "reference_section" => {
            "id" => reference_section.id,
            "taxon_id" => reference_section.taxon_id,
            "position" => reference_section.position,
            "title_taxt" => reference_section.title_taxt,
            "references_taxt" => reference_section.references_taxt,
            "subtitle_taxt" => reference_section.subtitle_taxt,
            "created_at" => reference_section.created_at.as_json,
            "updated_at" => reference_section.updated_at.as_json
          }
        }
      )
    end

    specify { expect(get(:show, params: { id: reference_section.id })).to have_http_status :ok }
  end
end
