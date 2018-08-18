require "spec_helper"

describe Wikipedia::TaxonList do
  let!(:taxon) { create :genus }
  let!(:extant_species) { create_species "Atta cephalotes", genus: taxon }
  let!(:fossil_species) { create_species "Atta mexicana", genus: taxon, fossil: true }

  describe "#call" do
    it "outputs a wiki-formatted list" do
      results = described_class[taxon]

      expect(results).to include "diversity_link = #Species"
      expect(results).to include "==Species=="
      expect(results).to include "* ''[[Atta cephalotes]]'' <small>"
      expect(results).to include "* †''[[Atta mexicana]]'' <small>"
    end
  end
end
