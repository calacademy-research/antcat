# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::TaxaController, as: :visitor do
  describe "GET index" do
    specify do
      taxon = create :family
      get :index
      expect(json_response).to eq([taxon.as_json(root: true)])
    end

    specify { expect(get(:index)).to have_http_status :ok }
  end

  describe "GET show" do
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

  describe "GET search" do
    let!(:taxon) { create :species, name_string: 'Atta minor maxus' }

    specify do
      get :search, params: { string: 'maxus' }
      expect(json_response).to eq(
        [
          { "id" => taxon.id, "name" => taxon.name_cache }
        ]
      )
    end

    context "when there are no search matches" do
      it 'returns an empty array' do
        get :search, params: { string: 'pizza' }
        expect(json_response).to eq([])
      end
    end
  end
end
