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

  it "can have subspecies, which are its children" do
    species = create :species
    robusta = create :subspecies, species: species
    saltensis = create :subspecies, species: species

    expect(species.subspecies).to eq [robusta, saltensis]
    expect(species.children).to eq species.subspecies
  end

  describe "#update_parent" do
    let!(:subfamily) { create :subfamily }
    let!(:genus) { create :genus, subfamily: subfamily }
    let!(:species) { create :species, subfamily: subfamily, genus: genus }

    it "assigns the subfamily of its descendants" do
      # TODO: Commented out (hmm) because it's not supported and will raise (since subspecies names are not updated).
      # subspecies = create :subspecies, species: species, genus: genus, subfamily: subfamily
      new_genus = create :genus

      expect(new_genus.subfamily).to_not eq subfamily

      # Test initial.
      expect(species.reload.subfamily).to eq subfamily
      expect(species.reload.genus).to eq genus
      # TODO: Commented out, see above.
      # expect(subspecies.reload.genus).to eq genus
      # expect(subspecies.reload.subfamily).to eq subfamily

      # Act.
      species.update_parent new_genus
      species.save!

      # Assert.
      expect(species.reload.subfamily).to eq new_genus.subfamily
      expect(species.reload.genus).to eq new_genus
      # TODO: Commented out, see above.
      # expect(subspecies.reload.genus).to eq new_genus
      # expect(subspecies.reload.subfamily).to eq new_genus.subfamily
    end

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
end
