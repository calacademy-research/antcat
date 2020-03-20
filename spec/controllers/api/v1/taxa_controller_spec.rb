require 'rails_helper'

describe Api::V1::TaxaController do
  describe "GET index" do
    it "gets all taxa greater than a given number" do
      create :genus
      create :species
      species = create :species

      get :index, params: { starts_at: species.id }

      expect(json_response[0]['species']['id']).to eq species.id
      expect(json_response.count).to eq 1
    end

    it "gets all taxa" do
      taxon = create :family

      get :index

      expect(response.body.to_s).to include taxon.name.name
      expect(json_response.count).to eq 1
    end

    specify { expect(get(:index)).to have_http_status :ok }
  end

  describe "GET show" do
    context 'when record does not exists' do
      specify { expect(get(:show, params: { id: 0 })).to have_http_status :not_found }
    end

    context 'when record exists' do
      let!(:taxon) { create :species }

      specify do
        get :show, params: { id: taxon.id }
        expect(json_response).to eq(
          {
            "species" => {
              "auto_generated" => false,
              "collective_group_name" => false,
              "created_at" => taxon.created_at.as_json,
              "current_valid_taxon_id" => nil,
              "family_id" => nil,
              "fossil" => false,
              "genus_id" => taxon.genus_id,
              "headline_notes_taxt" => nil,
              "hol_id" => nil,
              "homonym_replaced_by_id" => nil,
              "hong" => false,
              "ichnotaxon" => false,
              "id" => taxon.id,
              "incertae_sedis_in" => nil,
              "name_cache" => taxon.name_cache,
              "name_html_cache" => taxon.name_html_cache,
              "name_id" => taxon.name_id,
              "nomen_nudum" => false,
              "origin" => nil,
              "original_combination" => false,
              "protonym_id" => taxon.protonym_id,
              "species_id" => nil,
              "status" => "valid",
              "subfamily_id" => taxon.subfamily_id,
              "subgenus_id" => nil,
              "subspecies_id" => nil,
              "tribe_id" => taxon.tribe_id,
              "type_taxon_id" => nil,
              "type_taxt" => nil,
              "unresolved_homonym" => false,
              "updated_at" => taxon.updated_at.as_json,
              "author_citation" => taxon.author_citation
            }
          }
        )
      end

      specify { expect(get(:show, params: { id: taxon.id })).to have_http_status :ok }
    end
  end

  describe "GET search" do
    before { create :species, name_string: 'Atta minor maxus' }

    it "searches for taxa" do
      get :search, params: { string: 'maxus' }
      expect(response.body.to_s).to include "maxus"
    end

    it 'returns HTTP 200' do
      get :search, params: { string: 'maxus' }
      expect(response).to have_http_status :ok
    end

    context "when there are no search matches" do
      it 'returns HTTP 404' do
        get :search, params: { string: 'maxuus' }
        expect(response).to have_http_status :not_found
      end
    end
  end
end
