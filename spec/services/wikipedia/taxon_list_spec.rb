require "spec_helper"

describe Wikipedia::TaxonList do
  let!(:taxon) { create :genus }

  before do
    create :species, name_string: "Atta cephalotes", genus: taxon
    create :species, :fossil, name_string: "Atta mexicana", genus: taxon
  end

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
