require 'rails_helper'

describe SpeciesGroupTaxon do
  it "has its subfamily set from its genus" do
    genus = create :genus
    expect(genus.subfamily).not_to be_nil

    taxon = create :species, genus: genus, subfamily: nil
    expect(taxon.subfamily).to eq genus.subfamily
  end

  describe "#recombination?" do
    context "when genus part of name is different than genus part of protonym" do
      let!(:species) { create :species, name_string: 'Atta minor' }
      let!(:protonym_name) { create :species_name, name: 'Eciton minor' }

      it "is a recombination" do
        expect(species.protonym).to receive(:name).and_return protonym_name
        expect(species).to be_recombination
      end
    end

    context "when genus part of name is same as genus part of protonym" do
      let!(:species) { create :species, name_string: 'Atta minor maxus' }
      let!(:protonym_name) { create :subspecies_name, name: 'Atta minor minus' }

      it "is not a recombination" do
        expect(species.protonym).to receive(:name).and_return protonym_name
        expect(species).not_to be_recombination
      end
    end
  end
end
