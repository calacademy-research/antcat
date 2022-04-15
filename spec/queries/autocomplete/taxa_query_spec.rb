# frozen_string_literal: true

require 'rails_helper'

describe Autocomplete::TaxaQuery, :search do
  context 'when a taxon ID is given' do
    let!(:taxon) { create :any_taxon }

    specify { expect(described_class[taxon.id.to_s]).to eq [taxon] }
  end

  context "with `rank`" do
    let!(:family) { create :family, name_string: "Formicidae" }
    let!(:genus) { create :genus, name_string: "Formica" }

    it 'only returns matches with that rank' do
      Sunspot.commit

      expect(described_class["Formi", rank: Rank::GENUS]).to eq [genus]
      expect(described_class["Formi", rank: Rank::FAMILY]).to eq [family]
    end

    it 'can filter by more then one rank' do
      Sunspot.commit

      expect(described_class["Formi", rank: [Rank::FAMILY, Rank::GENUS]]).
        to match_array [family, genus]
    end
  end

  describe 'searching by taxon name' do
    let!(:taxon) { create :family, name_string: "Formicidae" }

    before do
      create :any_taxon # Non-match.
      Sunspot.commit
    end

    specify do
      expect(described_class['Formi']).to eq [taxon]
    end
  end

  describe 'searching by protonym author names' do
    let!(:taxon) do
      protonym = create :protonym, authorship_reference: create(:any_reference, author_string: 'Batiatus')
      create :genus, protonym: protonym
    end

    before do
      create :any_taxon # Non-match.
      Sunspot.commit
    end

    specify do
      expect(described_class['bat']).to eq [taxon]
    end
  end

  describe 'searching by protonym author year' do
    let!(:taxon_2005) do
      protonym = create :protonym, authorship_reference: create(:any_reference, year: 2005)
      create :genus, protonym: protonym
    end
    let!(:taxon_1995) do
      protonym = create :protonym, authorship_reference: create(:any_reference, year: 1995)
      create :family, protonym: protonym
    end

    before do
      Sunspot.commit
    end

    specify do
      expect(described_class['200']).to include(taxon_2005)
      expect(described_class['200']).not_to include(taxon_1995)
      expect(described_class['199']).to include(taxon_1995)
    end
  end

  describe 'searching in different fields at the same time' do
    let!(:taxon) do
      protonym = create :protonym, authorship_reference: create(:any_reference, author_string: 'Batiatus', year: 2005)
      create :genus, name_string: 'Lasius', protonym: protonym
    end

    before do
      create :any_taxon # Non-match.
      Sunspot.commit
    end

    specify do
      expect(described_class['bat las 2005']).to eq [taxon]
      expect(described_class['bat las 2006']).to eq []
    end
  end
end
