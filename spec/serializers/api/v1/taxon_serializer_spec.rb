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
            "current_taxon_id" => nil,
            "family_id" => nil,
            "fossil" => false,
            "genus_id" => taxon.genus.id,
            "hol_id" => nil,
            "homonym_replaced_by_id" => nil,
            "hong" => false,
            "ichnotaxon" => false,
            "incertae_sedis_in" => nil,
            "name_cache" => taxon.name.name,
            "name_html_cache" => taxon.name.name_html,
            "name_id" => taxon.name.id,
            "original_combination" => false,
            "protonym_id" => taxon.protonym.id,
            "species_id" => nil,
            "status" => Status::VALID,
            "subfamily_id" => nil,
            "subgenus_id" => nil,
            "subspecies_id" => nil,
            "tribe_id" => nil,
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
