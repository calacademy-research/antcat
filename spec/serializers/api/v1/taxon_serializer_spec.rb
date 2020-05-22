# frozen_string_literal: true

require 'rails_helper'

describe Api::V1::TaxonSerializer do
  describe "#as_json" do
    let!(:taxon) { create :species }

    specify do
      expect(described_class.new(taxon).as_json).to eq(
        {
          "species" => {
            "id" => taxon.id,
            "auto_generated" => false,
            "collective_group_name" => false,
            "current_valid_taxon_id" => nil,
            "family_id" => nil,
            "fossil" => false,
            "genus_id" => taxon.genus_id,
            "hol_id" => nil,
            "homonym_replaced_by_id" => nil,
            "hong" => false,
            "ichnotaxon" => false,
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
            "unresolved_homonym" => false,

            "created_at" => taxon.created_at.as_json,
            "updated_at" => taxon.updated_at.as_json,

            "author_citation" => taxon.author_citation
          }
        }
      )
    end
  end
end
