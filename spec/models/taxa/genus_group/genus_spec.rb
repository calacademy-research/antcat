require 'rails_helper'

describe Genus do
  let(:tribe) { create :tribe, subfamily: subfamily }
  let(:subfamily) { create :subfamily }
  let(:genus) { create :genus }

  describe 'relations' do
    it { is_expected.to have_many(:species).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:subspecies).dependent(:restrict_with_error) }
    it { is_expected.to have_many(:subgenera).dependent(:restrict_with_error) }
  end

  it "can have species, which are its children" do
    species = create :species, genus: genus
    other_species = create :species, genus: genus

    expect(genus.species).to eq [species, other_species]
    expect(genus.children).to eq genus.species
  end

  describe "#without_subfamily" do
    let!(:cariridris) { create :genus, subfamily: nil }

    it "returns genera with no subfamily" do
      expect(described_class.without_subfamily.all).to eq [cariridris]
    end
  end

  describe "#without_tribe" do
    it "returns genera with no tribe" do
      create :genus, tribe: tribe, subfamily: tribe.subfamily
      taxon = create :genus, subfamily: tribe.subfamily, tribe: nil

      expect(described_class.without_tribe.all).to eq [taxon]
    end
  end

  describe "#descendants" do
    context "when there are no descendants" do
      specify { expect(genus.descendants).to eq [] }
    end

    context "when there are descendants" do
      let(:species) { create :species, genus: genus }
      let(:subgenus) { create :subgenus, genus: genus }
      let(:subspecies) { create :subspecies, genus: genus, species: species }

      it "returns all the species, subspecies and subgenera of the genus" do
        expect(genus.descendants).to match_array [species, subgenus, subspecies]
      end
    end
  end

  describe "#parent" do
    context "when genus has no subfamily" do
      let!(:genus) { create :genus, subfamily: nil, tribe: nil }

      specify { expect(genus.parent).to eq nil }
    end

    context "when genus has a subfamily" do
      let!(:genus) { create :genus, subfamily: subfamily, tribe: nil }

      specify { expect(genus.parent).to eq genus.subfamily }
    end

    context "when genus has a tribe" do
      let(:genus) { create :genus, tribe: tribe }

      specify { expect(genus.parent).to eq tribe }
    end
  end

  describe "#parent=" do
    let!(:genus) { create :genus }

    it "assigns to both tribe and subfamily when parent is a tribe" do
      genus.parent = tribe

      expect(genus.tribe).to eq tribe
      expect(genus.subfamily).to eq subfamily
    end
  end

  describe "#update_parent" do
    let(:genus_with_tribe) { create :genus, tribe: tribe }

    it "assigns to both tribe and subfamily when parent is a tribe" do
      genus = create :genus
      genus.update_parent tribe

      expect(genus.tribe).to eq tribe
      expect(genus.subfamily).to eq subfamily
    end

    it "assigns the subfamily when the tribe is nil, and set the tribe to nil" do
      genus_with_tribe.update_parent subfamily

      expect(genus_with_tribe.tribe).to eq nil
      expect(genus_with_tribe.subfamily).to eq subfamily
    end

    it "clears both subfamily and tribe when the new parent is a family" do
      family = create :family
      expect(genus_with_tribe.tribe).to eq tribe # Trigger FactoryBot.
      genus_with_tribe.update_parent family
      expect(genus_with_tribe.tribe).to eq nil
      expect(genus_with_tribe.subfamily).to eq nil
    end

    it "clears both subfamily and tribe when the new parent is nil" do
      expect(genus_with_tribe.tribe).to eq tribe # Trigger FactoryBot.
      genus_with_tribe.update_parent nil
      expect(genus_with_tribe.tribe).to eq nil
      expect(genus_with_tribe.subfamily).to eq nil
    end

    it "assigns the subfamily of its descendants" do
      species = create :species, genus: genus_with_tribe
      create :subspecies, species: species, genus: genus_with_tribe

      # Test initial.
      expect(genus_with_tribe.reload.subfamily).to eq subfamily
      expect(genus_with_tribe.reload.species.first.subfamily).to eq subfamily
      expect(genus_with_tribe.reload.subspecies.first.subfamily).to eq subfamily
      expect(species.reload.subfamily).to eq subfamily

      # Act.
      new_subfamily = create :subfamily
      new_tribe = create :tribe, subfamily: new_subfamily
      genus_with_tribe.update_parent new_tribe
      genus_with_tribe.save!

      # Assert.
      expect(genus_with_tribe.reload.tribe).to eq new_tribe
      expect(genus_with_tribe.reload.species.first.subfamily).to eq new_subfamily
      expect(genus_with_tribe.reload.subspecies.first.subfamily).to eq new_subfamily
    end
  end

  describe "#find_epithet_in_genus" do
    let!(:species) { create :species, name_string: 'Atta serratula' }

    context "when nothing matches" do
      specify { expect(genus.find_epithet_in_genus('sdfsdf')).to eq [] }
    end

    it "returns matches" do
      expect(species.genus.find_epithet_in_genus('serratula')).to eq [species]
    end

    describe "mandatory spelling changes" do
      it "finds -a when asked to find -us" do
        expect(species.genus.find_epithet_in_genus('serratulus')).to eq [species]
      end
    end
  end
end
