# frozen_string_literal: true

require 'rails_helper'

describe Taxa::CopyAttributes do
  describe "#call" do
    let!(:taxon) { build_stubbed :species }

    it "returns a hash with the copied attriutes" do
      expect(described_class[taxon]).to eq(
        "fossil" => taxon.fossil,
        "status" => taxon.status,
        "homonym_replaced_by_id" => taxon.homonym_replaced_by_id,
        "incertae_sedis_in" => taxon.incertae_sedis_in,
        "protonym_id" => taxon.protonym_id,
        "hong" => taxon.hong,
        "unresolved_homonym" => taxon.unresolved_homonym,
        "current_taxon_id" => taxon.current_taxon_id,
        "ichnotaxon" => taxon.ichnotaxon
      )
    end
  end
end
