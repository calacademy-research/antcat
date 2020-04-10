# frozen_string_literal: true

require 'rails_helper'

describe Exporters::Taxa::TaxaAsTxt do
  describe "#call" do
    it "formats in text style, rather than HTML" do
      latreille = create :author_name, name: 'Latreille, P. A.'
      science = create :journal, name: 'Science'
      reference = create :article_reference,
        author_names: [latreille], citation_year: '1809',
        title: "*Atta*", journal: science,
        series_volume_issue: '(1)', pagination: '3', doi: '123'
      taxon = create :genus, :unavailable, :incertae_sedis_in_subfamily, nomen_nudum: true
      taxon.protonym.authorship.update!(reference: reference)

      expect(described_class[[taxon]]).to eq "#{taxon.name_cache} incertae sedis in subfamily, nomen nudum\n" \
        "Latreille, P. A. 1809. Atta. Science (1):3. DOI: 123   #{reference.id}\n\n"
    end

    context 'when taxon is a synonym' do
      let(:taxon) { create :genus, :synonym, current_valid_taxon: create(:genus) }

      specify do
        expect(described_class[[taxon]]).
          to include "#{taxon.name_cache} synonym of #{taxon.current_valid_taxon.name_cache}\n"
      end
    end

    context 'when taxon is a homonym' do
      let(:taxon) { create :genus, :homonym }

      specify do
        expect(described_class[[taxon]]).
          to include "#{taxon.name_cache} homonym replaced by #{taxon.homonym_replaced_by.name_cache}\n"
      end
    end
  end
end
