require "spec_helper"

describe Wikipedia::TaxonList do
  let(:atta) { create_genus "Atta" }
  let(:extant_species) { create_species "Atta cephalotes" }
  let(:fossil_species) { create_species "Atta mexicana", fossil: true }

  describe "#children" do
    it "outputs a wiki-formatted list" do
      # We cannot trust the factories, so set parent here.
      extant_species.genus = atta
      fossil_species.genus = atta
      extant_species.save!
      fossil_species.save!

      # Act and test.
      results = Wikipedia::TaxonList.new(atta).children

      expect(results).to include "diversity_link = #Species"
      expect(results).to include "==Species=="
      expect(results).to include "* ''[[Atta cephalotes]]'' <small>"
      expect(results).to include "* †''[[Atta mexicana]]'' <small>"
    end
  end
end
