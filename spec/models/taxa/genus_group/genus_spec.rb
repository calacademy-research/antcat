require 'spec_helper'

describe Genus do
  let(:genus_with_tribe) { create :genus, tribe: tribe }
  let(:tribe) { create :tribe, subfamily: subfamily }
  let(:subfamily) { create :subfamily }
  let(:genus) { create :genus }

  it "can have species, which are its children" do
    species = create :species, genus: genus
    other_species = create :species, genus: genus

    expect(genus.species).to eq [species, other_species]
    expect(genus.children).to eq genus.species
  end

  it "uses the species's' genus, if nec." do
    species = create :species, genus: genus
    create :subspecies, species: species, genus: nil

    expect(genus.subspecies.count).to eq 1
  end

  describe "#statistics" do
    context "when 0 children" do
      specify { expect(genus.statistics).to eq({}) }
    end

    context "when 1 valid species" do
      before { create :species, genus: genus }

      specify do
        expect(genus.statistics).to eq extant: { species: { 'valid' => 1 } }
      end
    end

    context "when there are original combinations" do
      before do
        create :species, genus: genus
        create :species, :original_combination, genus: genus
      end

      it "ignores the original combinations" do
        expect(genus.statistics).to eq extant: { species: { 'valid' => 1 } }
      end
    end

    context "when 1 valid species and 2 synonyms" do
      before do
        create :species, genus: genus
        2.times { create :species, :synonym, genus: genus }
      end

      specify do
        expect(genus.statistics).to eq extant: {
          species: { 'valid' => 1, 'synonym' => 2 }
        }
      end
    end

    context "when 1 valid species with 2 valid subspecies" do
      before do
        species = create :species, genus: genus
        2.times { create :subspecies, species: species, genus: genus }
      end

      specify do
        expect(genus.statistics).to eq extant: {
          species: { 'valid' => 1 }, subspecies: { 'valid' => 2 }
        }
      end
    end

    context "when there are extinct species and subspecies" do
      before do
        species = create :species, genus: genus
        fossil_species = create :species, genus: genus, fossil: true
        create :subspecies, genus: genus, species: species, fossil: true
        create :subspecies, genus: genus, species: species
        create :subspecies, genus: genus, species: fossil_species, fossil: true
      end

      it "can differentiate extinct species and subspecies" do
        expect(genus.statistics).to eq(
          extant: {
            species: { 'valid' => 1 },
            subspecies: { 'valid' => 1 }
          },
          fossil: {
            species: { 'valid' => 1 },
            subspecies: { 'valid' => 2 }
          }
        )
      end
    end
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
      it "returns an empty array" do
        expect(genus.descendants).to eq []
      end
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
    context "when there's no subfamily" do
      let!(:genus) { create :genus, subfamily: nil, tribe: nil }

      specify { expect(genus.parent).to eq nil }
    end

    context "when there is one" do
      let!(:genus) { create :genus, subfamily: subfamily, tribe: nil }

      it "refers to the subfamily" do
        expect(genus.parent).to eq genus.subfamily
      end
    end

    context "when there is one" do
      it "refers to the tribe" do
        expect(genus_with_tribe.parent).to eq tribe
      end
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

    it "clears both subfamily and tribe when the new parent is nil" do
      expect(genus_with_tribe.tribe).to eq tribe # Trigger FactoryBot.
      genus_with_tribe.update_parent nil

      expect(genus_with_tribe.tribe).to eq nil
      expect(genus_with_tribe.subfamily).to eq nil
    end

    it "assigns the subfamily of its descendants" do
      species = create :species, genus: genus_with_tribe
      create :subspecies, species: species, genus: genus_with_tribe

      # test the initial subfamilies
      expect(genus_with_tribe.subfamily).to eq subfamily
      expect(genus_with_tribe.species.first.subfamily).to eq subfamily
      expect(genus_with_tribe.subspecies.first.subfamily).to eq subfamily

      # test the updated subfamilies
      new_subfamily = create :subfamily
      new_tribe = create :tribe, subfamily: new_subfamily
      genus_with_tribe.update_parent new_tribe

      expect(genus_with_tribe.subfamily).to eq new_subfamily
      expect(genus_with_tribe.species.first.subfamily).to eq new_subfamily
      expect(genus_with_tribe.subspecies.first.subfamily).to eq new_subfamily
    end
  end

  describe "#find_epithet_in_genus" do
    let!(:species) { create_species 'Atta serratula' }

    context "when nothing matches" do
      specify { expect(genus.find_epithet_in_genus('sdfsdf')).to eq [] }
    end

    it "returns the one item" do
      expect(species.genus.find_epithet_in_genus('serratula')).to eq [species]
    end

    context "mandatory spelling changes" do
      it "finds -a when asked to find -us" do
        expect(species.genus.find_epithet_in_genus('serratulus')).to eq [species]
      end
    end
  end
end
