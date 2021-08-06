# frozen_string_literal: true

require 'rails_helper'

describe Subspecies do
  describe 'relations' do
    it { is_expected.to have_many(:infrasubspecies).dependent(:restrict_with_error) }

    describe 'required `belongs_to`' do
      subject(:taxon) { create :subspecies }

      it { is_expected.to belong_to(:genus).required }
      it { is_expected.to belong_to(:species).required }
    end
  end

  describe 'validations' do
    it { is_expected.to validate_absence_of(:family_id) }
    it { is_expected.to validate_absence_of(:tribe_id) }
    it { is_expected.to validate_absence_of(:subspecies_id) }
  end

  describe "#update_parent" do
    let(:subspecies) { create :subspecies }
    let(:new_parent) { create :species }

    it "sets all the parent fields" do
      subspecies.update_parent new_parent
      subspecies.save!

      expect(subspecies.reload.species).to eq new_parent
      expect(subspecies.reload.genus).to eq new_parent.genus
      expect(subspecies.reload.subfamily).to eq new_parent.subfamily
    end

    describe "updating the name" do
      let(:subspecies) { create :subspecies, name_string: 'Atta major minor' }
      let(:new_parent) { create :species, name_string: 'Eciton nigrus' }

      specify do
        subspecies.update_parent new_parent

        subspecies_name = subspecies.name
        expect(subspecies_name.name).to eq 'Eciton nigrus minor'
        expect(subspecies_name.epithet).to eq 'minor'
      end
    end

    context "when name already exists" do
      let!(:existing_subspecies_name) { create :subspecies_name, name: 'Eciton niger minor' }
      let!(:subspecies) { create :subspecies, name_string: 'Atta niger minor' }
      let(:new_parent) { create :species, name_string: 'Eciton niger' }

      context "when name is used by a different taxon" do
        before do
          create :subspecies, name: existing_subspecies_name
        end

        it "raises" do
          expect { subspecies.update_parent new_parent }.to raise_error Taxa::TaxonExists
        end
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
