require 'rails_helper'

describe SpeciesGroupTaxon do
  describe 'validations' do
    describe 'protonym names' do
      let(:taxon) { create :species }
      let(:genus_name) { create :genus_name }

      it 'must have genus-group protonym names' do
        expect { taxon.protonym.name = genus_name }.to change { taxon.valid? }.to(false)
        expect(taxon.errors[:base]).
          to eq ["Species and subspecies must have protonyms with species-group names"]
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
