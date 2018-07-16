require 'spec_helper'

describe Genus do
  it { is_expected.to belong_to :tribe }
  it { is_expected.to have_many :species }
  it { is_expected.to have_many :subgenera }
  it { is_expected.to have_many :subspecies }

  let(:genus) { create :genus, name: create(:genus_name, name: 'Atta') }
  let(:subfamily) { create :subfamily, name: create(:name, name: 'Myrmicinae') }
  let(:tribe) { create :tribe, name: create(:name, name: 'Attini'), subfamily: subfamily }
  let(:genus_with_tribe) { create :genus, name: create(:genus_name, name: 'Atta'), tribe: tribe }

  it "can have species, which are its children" do
    robusta = create :species, name: create(:name, name: "robusta"), genus: genus
    saltensis = create :species, name: create(:name, name: "saltensis"), genus: genus

    expect(genus.species).to eq [robusta, saltensis]
    expect(genus.children).to eq genus.species
  end

  it "should use the species's' genus, if nec." do
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
      atta = create :genus, subfamily: tribe.subfamily, tribe: nil

      expect(described_class.without_tribe.all).to eq [atta]
    end
  end

  describe "#siblings" do
    context "when there are no others" do
      it "returns itself" do
        expect(genus_with_tribe.siblings).to eq [genus_with_tribe]
      end
    end

    context "when there are other genera in the same tribe" do
      let(:genus) { create :genus, tribe: tribe, subfamily: tribe.subfamily }
      let(:another_genus) { create :genus, tribe: tribe, subfamily: tribe.subfamily }

      it "returns itself and its tribe's other genera" do
        expect(genus.siblings).to match_array [genus, another_genus]
      end
    end

    context "when there's no subfamily" do
      let(:genus) { create :genus, subfamily: nil, tribe: nil }
      let(:another_genus) { create :genus, subfamily: nil, tribe: nil }

      it "returns all the genera with no subfamilies" do
        expect(genus.siblings).to match_array [genus, another_genus]
      end
    end

    context "when there's no tribe" do
      let(:genus) { create :genus, subfamily: subfamily, tribe: nil }
      let(:another_genus) { create :genus, subfamily: subfamily, tribe: nil }

      before { create :genus, tribe: tribe, subfamily: subfamily }

      it "returns the other genera in its subfamily without tribes" do
        expect(genus.siblings).to match_array [genus, another_genus]
      end
    end
  end

  describe "#descendants" do
    context "when there are no descendants" do
      it "returns an empty array" do
        expect(genus.descendants).to eq []
      end
    end

    context "when there are descendants" do
      let(:species) { create_species genus: genus }
      let(:subgenus) { create_subgenus genus: genus }
      let(:subspecies) { create_subspecies genus: genus, species: species }

      it "returns all the species, subspecies and subgenera of the genus" do
        expect(genus.descendants).to match_array [species, subgenus, subspecies]
      end
    end
  end

  describe "#parent" do
    context "when there's no subfamily" do
      let!(:genus) { create_genus subfamily: nil, tribe: nil }

      it "is nil" do
        expect(genus.parent).to be_nil
      end
    end

    context "when there is one" do
      let!(:genus) { create_genus subfamily: subfamily, tribe: nil }

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
    let!(:genus) { create_genus 'Aneuretus', protonym: create(:protonym) }

    it "assigns to both tribe and subfamily when parent is a tribe" do
      genus.parent = tribe

      expect(genus.tribe).to eq tribe
      expect(genus.subfamily).to eq subfamily
    end
  end

  describe "#update_parent" do
    it "assigns to both tribe and subfamily when parent is a tribe" do
      genus = create_genus 'Aneuretus', protonym: create(:protonym)
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
      species = create_species genus: genus_with_tribe
      create_subspecies species: species, genus: genus_with_tribe

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

    it "returns nil if nothing matches" do
      expect(genus.find_epithet_in_genus 'sdfsdf').to eq nil
    end

    it "returns the one item" do
      expect(species.genus.find_epithet_in_genus 'serratula').to eq [species]
    end

    context "mandatory spelling changes" do
      it "finds -a when asked to find -us" do
        expect(species.genus.find_epithet_in_genus 'serratulus').to eq [species]
      end
    end
  end
end
