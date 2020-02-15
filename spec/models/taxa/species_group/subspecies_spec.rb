require 'rails_helper'

describe Subspecies do
  it { is_expected.to validate_presence_of :genus }
  it { is_expected.to validate_presence_of :species }

  describe 'relations' do
    it { is_expected.to have_many(:infrasubspecies).dependent(:restrict_with_error) }
  end

  describe 'callbacks' do
    describe '#set_genus' do
      let(:genus) { create :genus }
      let(:species) { create :species, genus: genus }

      it "has its genus assigned from its species" do
        subspecies = create :subspecies, genus: nil, species: species
        expect(subspecies.genus).to eq genus
      end
    end
  end

  describe "#update_parent" do
    let(:subspecies) { create :subspecies }
    let(:new_parent) { create :species }

    it "sets all the parent fields" do
      subspecies.update_parent new_parent
      subspecies.save!

      expect(subspecies.reload.species).to eq new_parent
      expect(subspecies.reload.genus).to eq new_parent.genus
      expect(subspecies.reload.subgenus).to eq new_parent.subgenus
      expect(subspecies.reload.subfamily).to eq new_parent.subfamily
    end

    describe "updating the name" do
      let(:subspecies) { create :subspecies, name_string: 'Atta major medius minor' }
      let(:new_parent) { create :species, name_string: 'Eciton nigrus' }

      specify do
        subspecies.update_parent new_parent

        subspecies_name = subspecies.name
        expect(subspecies_name.name).to eq 'Eciton nigrus medius minor'
        expect(subspecies_name.epithet).to eq 'minor'
      end
    end

    context 'when subspecies has infrasubspeices' do
      let(:subspecies) { create :subspecies }

      before do
        create :infrasubspecies, subspecies: subspecies
      end

      specify do
        new_species = create :species
        expect { subspecies.update_parent new_species }.to raise_error(Taxa::TaxonHasInfrasubspecies)
      end
    end
  end
end
