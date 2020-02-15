require 'rails_helper'

describe SpeciesGroupTaxon do
  describe 'callbacks' do
    describe '#set_subfamily' do
      let!(:genus) { create :genus }

      it "has its subfamily assigned from its genus" do
        species = create :species, genus: genus, subfamily: nil
        expect(species.subfamily).to eq genus.subfamily
      end
    end
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
