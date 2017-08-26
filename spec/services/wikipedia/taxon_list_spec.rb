require "spec_helper"

describe Wikipedia::TaxonList do
  let(:atta) { create_genus "Atta" }
  let(:extant_species) { create_species "Atta cephalotes" }
  let(:fossil_species) { create_species "Atta mexicana", fossil: true }

  before do
    # We cannot trust the factories, so set parent here.
    extant_species.update! genus: atta
    fossil_species.update! genus: atta
  end

  describe "#call" do
    it "outputs a wiki-formatted list" do
      results = described_class.new(atta).call

      expect(results).to include "diversity_link = #Species"
      expect(results).to include "==Species=="
      expect(results).to include "* ''[[Atta cephalotes]]'' <small>"
      expect(results).to include "* †''[[Atta mexicana]]'' <small>"
    end
  end
end
