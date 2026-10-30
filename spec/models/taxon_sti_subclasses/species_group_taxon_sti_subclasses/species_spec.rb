# frozen_string_literal: true

require 'rails_helper'

describe Species do
  describe 'relations' do
    it { is_expected.to have_many(:subspecies).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:infrasubspecies).dependent(:restrict_with_error) }

    describe 'required `belongs_to`' do
      subject(:taxon) { create :species }

      it { is_expected.to belong_to(:genus).required }
    end
  end

  describe 'validations' do
    it { is_expected.to validate_absence_of(:family_id) }
    it { is_expected.to validate_absence_of(:tribe_id) }
    it { is_expected.to validate_absence_of(:species_id) }
    it { is_expected.to validate_absence_of(:subspecies_id) }
  end

  describe "#update_parent" do
    let!(:subfamily) { create :subfamily }
    let!(:genus) { create :genus, subfamily: subfamily }
    let!(:species) { create :species, subfamily: subfamily, genus: genus }

    describe "updating the name" do
      let(:species) { create :species, name_string: 'Atta niger' }
      let(:new_parent) { create :genus, name_string: 'Eciton' }

      it "replaces the genus part of the name" do
        expect do
          species.update_parent new_parent
          species.save!
        end.
          to change { species.reload.name.name }.
          from('Atta niger').
          to('Eciton niger')
      end
    end

    context "when name already exists" do
      let(:existing_species_name) { create :species_name, name: 'Eciton niger' }
      let(:species) { create :species, name_string: 'Atta niger' }
      let(:new_parent) { create :genus, name_string: 'Eciton' }

      context "when name is used by a different taxon" do
        before do
          create :species, name: existing_species_name
        end

        it "raises" do
          expect { species.update_parent new_parent }.to raise_error Taxa::TaxonExists
        end
      end
    end

    context 'when species has subspecies' do
      before do
        create :subspecies, species: species, genus: genus, subfamily: subfamily
      end

      specify do
        new_genus = create :genus
        expect { species.update_parent new_genus }.to raise_error(Taxa::TaxonHasSubspecies)
      end
    end
  end

  describe "moving between a genus and its subgenera" do
    let(:genus) { create :genus, name_string: 'Camponotus' }
    let(:subgenus) { create :subgenus, genus: genus, subfamily: genus.subfamily, name_string: 'Camponotus (Myrmentoma)' }
    let(:species) do
      create :species, genus: genus, subgenus: subgenus, subfamily: genus.subfamily, name_string: 'Camponotus foo'
    end

    it "clears the subgenus when the parent becomes a genus" do
      other_genus = create :genus, name_string: 'Colobopsis'

      species.update_parent other_genus
      species.save!

      expect(species.reload.subgenus).to eq nil
      expect(species.parent).to eq other_genus
      expect(species.name.name).to eq 'Colobopsis foo'
    end

    it "moves into a subgenus of its genus without renaming" do
      species_without_subgenus = create :species, genus: genus, subfamily: genus.subfamily, name_string: 'Camponotus bar'

      expect { species_without_subgenus.update_parent subgenus }.not_to raise_error
      species_without_subgenus.save!

      expect(species_without_subgenus.reload.subgenus).to eq subgenus
      expect(species_without_subgenus.name.name).to eq 'Camponotus bar'
    end
  end
end
