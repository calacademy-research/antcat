# frozen_string_literal: true

require 'rails_helper'

describe Exporters::Taxa::TaxaAsTxt do
  describe "#call" do
    it "formats in text style, rather than HTML" do
      protonym = create :protonym, :nomen_nudum
      taxon = create :genus, :unavailable, :incertae_sedis_in_subfamily, protonym: protonym
      reference = taxon.authorship_reference

      expect(described_class[[taxon]]).to eq "#{taxon.name_cache} incertae sedis in subfamily, nomen nudum\n" \
        "#{reference.decorate.plain_text}   #{reference.id}\n\n"
    end

    context 'when taxon is a synonym' do
      let(:taxon) { create :genus, :synonym, current_taxon: create(:genus) }

      specify do
        expect(described_class[[taxon]]).
          to include "#{taxon.name_cache} synonym of #{taxon.current_taxon.name_cache}\n"
      end
    end

    context 'when taxon is a homonym' do
      let(:taxon) { create :genus, :homonym }

      specify do
        expect(described_class[[taxon]]).
          to include "#{taxon.name_cache} homonym replaced by #{taxon.homonym_replaced_by.name_cache}\n"
      end
    end

    context "when taxon's protonym has a locality and a biogeographic region" do
      let!(:protonym) do
        create :protonym, :species_group_name, biogeographic_region: Protonym::NEARCTIC_REGION, locality: "USA"
      end
      let(:taxon) { create :species, protonym: protonym }

      specify do
        expect(described_class[[taxon]]).to include "#{taxon.name_cache} valid USA. Nearctic.\n"
      end
    end
  end
end
