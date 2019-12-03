require 'rails_helper'

describe Taxa::TaxonAndAncestors do
  describe "#call" do
    let!(:taxon) { create :subspecies }

    specify do
      results = described_class[taxon]

      expect(results.size).to eq 5
      expect(results[0]).to eq taxon.species.genus.tribe.subfamily
      expect(results[1]).to eq taxon.species.genus.tribe
      expect(results[2]).to eq taxon.species.genus
      expect(results[3]).to eq taxon.species
      expect(results[4]).to eq taxon
    end
  end
end
