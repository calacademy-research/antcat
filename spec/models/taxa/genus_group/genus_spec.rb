require 'spec_helper'

describe Genus do
  let(:genus) { create :genus, name: create(:genus_name, name: 'Atta') }
  let(:subfamily) { create :subfamily, name: create(:name, name: 'Myrmicinae')}
  let(:tribe) { create :tribe, name: create(:name, name: 'Attini'), subfamily: subfamily }
  let(:genus_with_tribe) { create :genus, name: create(:genus_name, name: 'Atta'), tribe: tribe }

  it "can have a tribe" do
    expect(genus_with_tribe.tribe).to eq tribe # trigger FactoryGirl
    expect(Genus.find_by_name('Atta').tribe).to eq tribe
  end

  it "can have species, which are its children" do
    %w(robusta saltensis).each do |name|
      create :species, name: create(:name, name: name), genus: genus
    end

    atta = Genus.find_by_name 'Atta'
    expect(atta.species.map(&:name).map(&:to_s)).to match_array ['robusta', 'saltensis']
    expect(atta.children).to eq atta.species
  end

  it "can have subspecies" do
    create :subspecies, genus: genus
    expect(genus.subspecies.count).to eq 1
  end

  it "should use the species's' genus, if nec." do
    species = create :species, genus: genus
    create :subspecies, species: species, genus: nil
    expect(genus.subspecies.count).to eq 1
  end

  it "can have subgenera" do
    %w(robusta saltensis).each do |name|
      create :subgenus, name: create(:name, name: name), genus: genus
    end

    atta = Genus.find_by_name 'Atta'
    subgenera_names = atta.subgenera.map(&:name).map(&:to_s)
    expect(subgenera_names).to match_array ['robusta', 'saltensis']
  end

  describe "#statistics" do
    it "handles 0 children" do
      expect(genus.statistics).to eq({})
    end

    it "handles 1 valid species" do
      create :species, genus: genus
      expect(genus.statistics).to eq extant: { species: { 'valid' => 1 } }
    end

    it "ignores original combinations" do
      create :species, genus: genus
      create :species, status: 'original combination', genus: genus

      expect(genus.statistics).to eq extant: { species: { 'valid' => 1 } }
    end

    it "handles 1 valid species and 2 synonyms" do
      create :species, genus: genus
      2.times { create :species, genus: genus, status: 'synonym' }

      expect(genus.statistics).to eq extant: {
        species: { 'valid' => 1, 'synonym' => 2 }
      }
    end

    it "handles 1 valid species with 2 valid subspecies" do
      species = create :species, genus: genus
      2.times { create :subspecies, species: species, genus: genus }

      expect(genus.statistics).to eq extant: {
        species: { 'valid' => 1 }, subspecies: { 'valid' => 2 }
      }
    end

    it "can differentiate extinct species and subspecies" do
      species = create :species, genus: genus
      fossil_species = create :species, genus: genus, fossil: true
      create :subspecies, genus: genus, species: species, fossil: true
      create :subspecies, genus: genus, species: species
      create :subspecies, genus: genus, species: fossil_species, fossil: true

      expect(genus.statistics).to eq(
        extant: {
          species: { 'valid' => 1 },
          subspecies: {'valid' => 1 }
        },
        fossil: {
          species: { 'valid' => 1 },
          subspecies: { 'valid' => 2 }
        }
      )
    end
  end

  describe "#without_subfamily" do
    it "returns genera with no subfamily" do
      cariridris = create :genus, subfamily: nil
      expect(Genus.without_subfamily.all).to eq [cariridris]
    end
  end

  describe "#without_tribe" do
    it "returns genera with no tribe" do
      create :genus, tribe: tribe, subfamily: tribe.subfamily
      atta = create :genus, subfamily: tribe.subfamily, tribe: nil

      expect(Genus.without_tribe.all).to eq [atta]
    end
  end

  describe "#siblings" do
    it "returns itself when there are no others" do
      expect(genus_with_tribe.siblings).to eq [genus_with_tribe]
    end

    it "returns itself and its tribe's other genera" do
      genus = create :genus, tribe: tribe, subfamily: tribe.subfamily
      another_genus = create :genus, tribe: tribe, subfamily: tribe.subfamily

      expect(genus.siblings).to match_array [genus, another_genus]
    end

    context "when there's no subfamily" do
      it "returns all the genera with no subfamilies" do
        genus = create :genus, subfamily: nil, tribe: nil
        another_genus = create :genus, subfamily: nil, tribe: nil

        expect(genus.siblings).to match_array [genus, another_genus]
      end
    end

    context "when there's no tribe" do
      it "returns the other genera in its subfamily without tribes" do
        create :genus, tribe: tribe, subfamily: subfamily
        genus = create :genus, subfamily: subfamily, tribe: nil
        another_genus = create :genus, subfamily: subfamily, tribe: nil

        expect(genus.siblings).to match_array [genus, another_genus]
      end
    end
  end

  describe "#descendants" do
    it "returns an empty array if there are none" do
      expect(genus.descendants).to eq []
    end

    it "returns all the species" do
      species = create_species genus: genus
      expect(genus.descendants).to eq [species]
    end

    it "returns all the species, subspecies and subgenera of the genus" do
      species = create_species genus: genus
      subgenus = create_subgenus genus: genus
      subspecies = create_subspecies genus: genus, species: species

      expect(genus.descendants).to match_array [species, subgenus, subspecies]
    end
  end

  describe "#parent" do
    it "is nil, if there's no subfamily" do
      genus = create_genus subfamily: nil, tribe: nil
      expect(genus.parent).to be_nil
    end

    it "refers to the subfamily, if there is one" do
      genus = create_genus subfamily: subfamily, tribe: nil
      expect(genus.parent).to eq genus.subfamily
    end

    it "refers to the tribe, if there is one" do
      expect(genus_with_tribe.parent).to eq tribe
    end
  end

  describe "#parent=" do
    it "assigns to both tribe and subfamily when parent is a tribe" do
      genus = create_genus 'Aneuretus', protonym: create(:protonym)
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
      expect(genus_with_tribe.tribe).to eq tribe # trigger FactoryGirl
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
    let!(:species) { create_species 'Atta serratula'}

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
