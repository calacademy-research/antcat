require 'spec_helper'

describe Taxa::CopyAttributes do
  describe "#call" do
    let!(:taxon) { build_stubbed :species }

    it "returns a hash with the copied attriutes" do
      expect(described_class[taxon]).to eq({
        "fossil" => taxon.fossil,
        "status" => taxon.status,
        "homonym_replaced_by_id" => taxon.homonym_replaced_by_id,
        "incertae_sedis_in" => taxon.incertae_sedis_in,
        "protonym_id" => taxon.protonym_id,
        "type_taxt" => taxon.type_taxt,
        "headline_notes_taxt" => taxon.headline_notes_taxt,
        "hong" => taxon.hong,
        "unresolved_homonym" => taxon.unresolved_homonym,
        "current_valid_taxon_id" => taxon.current_valid_taxon_id,
        "ichnotaxon" => taxon.ichnotaxon,
        "nomen_nudum" => taxon.nomen_nudum,
        "biogeographic_region" => taxon.biogeographic_region,
        "primary_type_information" => taxon.primary_type_information,
        "secondary_type_information" => taxon.secondary_type_information,
        "type_notes" => taxon.type_notes,
        "type_taxon_id" => taxon.type_taxon_id
      })
    end
  end
end
