# frozen_string_literal: true

require 'rails_helper'

describe Autocomplete::TaxaQuery, :search do
  context 'when a taxon ID is given' do
    let!(:taxon) { create :any_taxon }

    specify { expect(described_class[taxon.id.to_s]).to eq [taxon] }
  end

  context "when there are results" do
    let!(:family) { create :family, name_string: "Formicidae" }

    specify do
      Sunspot.commit

      expect(described_class["Formi"]).to eq [family]
    end

    context "with `rank`" do
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
  end
end
