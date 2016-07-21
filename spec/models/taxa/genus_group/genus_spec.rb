require 'spec_helper'

describe Genus do
  PaperTrail.enabled = true
  it "should have a tribe" do
    attini = create :tribe, name: create(:name, name: 'Attini'), subfamily: create(:subfamily, name: create(:name, name: 'Myrmicinae'))
    create :genus, name: create(:name, name: 'Atta'), tribe: attini
    expect(Genus.find_by_name('Atta').tribe).to eq(attini)
  end

  it "should have species, which are its children" do
    atta = create :genus, name: create(:name, name: 'Atta')
    create :species, name: create(:name, name: 'robusta'), genus: atta
    create :species, name: create(:name, name: 'saltensis'), genus: atta
    atta = Genus.find_by_name('Atta')
    expect(atta.species.map(&:name).map(&:to_s)).to match_array(['robusta', 'saltensis'])
    expect(atta.children).to eq(atta.species)
  end

  it "should have subspecies" do
    genus = create :genus
    create :subspecies, genus: genus
    expect(genus.subspecies.count).to eq(1)
  end

  it "should use the species's' genus, if nec." do
    genus = create :genus
    species = create :species, genus: genus
    create :subspecies, species: species, genus: nil
    expect(genus.subspecies.count).to eq(1)
  end

  it "should have subgenera" do
    atta = create :genus, name: create(:name, name: 'Atta')
    create :subgenus, name: create(:name, name: 'robusta'), genus: atta
    create :subgenus, name: create(:name, name: 'saltensis'), genus: atta
    atta = Genus.find_by_name('Atta')
    expect(atta.subgenera.map(&:name).map(&:to_s)).to match_array(['robusta', 'saltensis'])
  end

  describe "Statistics" do

    it "should handle 0 children" do
      genus = create :genus
      expect(genus.statistics).to eq({})
    end

    it "should handle 1 valid species" do
      genus = create :genus
      species = create :species, genus: genus
      expect(genus.statistics).to eq({extant: {species: {'valid' => 1}}})
    end

    it "should ignore original combinations" do
      genus = create_genus
      create :species, genus: genus
      create :species, status: 'original combination', genus: genus
      expect(genus.statistics).to eq({extant: {species: {'valid' => 1}}})
    end

    it "should handle 1 valid species and 2 synonyms" do
      genus = create :genus
      create :species, genus: genus
      2.times {create :species, genus: genus, status: 'synonym'}
      expect(genus.statistics).to eq({extant: {species: {'valid' => 1, 'synonym' => 2}}})
    end

    it "should handle 1 valid species with 2 valid subspecies" do
      genus = create :genus
      species = create :species, genus: genus
      2.times {create :subspecies, species: species, genus: genus}
      expect(genus.statistics).to eq({extant: {species: {'valid' => 1}, subspecies: {'valid' => 2}}})
    end

    it "should be able to differentiate extinct species and subspecies" do
      genus = create :genus
      species = create :species, genus: genus
      fossil_species = create :species, genus: genus, fossil: true
      create :subspecies, genus: genus, species: species, fossil: true
      create :subspecies, genus: genus, species: species
      create :subspecies, genus: genus, species: fossil_species, fossil: true
      expect(genus.statistics).to eq({
        extant: {species: {'valid' => 1}, subspecies: {'valid' => 1}},
        fossil: {species: {'valid' => 1}, subspecies: {'valid' => 2}},
      })
    end

    it "should be able to differentiate extinct species and subspecies" do
      genus = create :genus
      species = create :species, genus: genus
      fossil_species = create :species, genus: genus, fossil: true
      create :subspecies, genus: genus, species: species, fossil: true
      create :subspecies, genus: genus, species: species
      create :subspecies, genus: genus, species: fossil_species, fossil: true
      expect(genus.statistics).to eq({
        extant: {species: {'valid' => 1}, subspecies: {'valid' => 1}},
        fossil: {species: {'valid' => 1}, subspecies: {'valid' => 2}},
      })
    end

  end

  describe "Without subfamily" do
    it "should just return the genera with no subfamily" do
      cariridris = create :genus, subfamily: nil
      atta = create :genus
      expect(Genus.without_subfamily.all).to eq([cariridris])
    end
  end

  describe "Without tribe" do
    it "should just return the genera with no tribe" do
      tribe = create :tribe
      cariridris = create :genus, tribe: tribe, subfamily: tribe.subfamily
      atta = create :genus, subfamily: tribe.subfamily, tribe: nil
      expect(Genus.without_tribe.all).to eq([atta])
    end
  end

  describe "Siblings" do

    it "should return itself when there are no others" do
      create :genus
      tribe = create :tribe
      genus = create :genus, tribe: tribe, subfamily: tribe.subfamily
      expect(genus.siblings).to eq([genus])
    end

    it "should return itself and its tribe's other genera" do
      create :genus
      tribe = create :tribe
      genus = create :genus, tribe: tribe, subfamily: tribe.subfamily
      another_genus = create :genus, tribe: tribe, subfamily: tribe.subfamily
      expect(genus.siblings).to match_array([genus, another_genus])
    end

    it "when there's no subfamily, should return all the genera with no subfamilies" do
      create :genus
      genus = create :genus, subfamily: nil, tribe: nil
      another_genus = create :genus, subfamily: nil, tribe: nil
      expect(genus.siblings).to match_array([genus, another_genus])
    end

    it "when there's no tribe, return the other genera in its subfamily without tribes" do
      subfamily = create :subfamily
      tribe = create :tribe, subfamily: subfamily
      create :genus, tribe: tribe, subfamily: subfamily
      genus = create :genus, subfamily: subfamily, tribe: nil
      another_genus = create :genus, subfamily: subfamily, tribe: nil
      expect(genus.siblings).to match_array([genus, another_genus])
    end

  end

  describe "Species group descendants" do
    before do
      @genus = create_genus
    end
    it "should return an empty array if there are none" do
      expect(@genus.species_group_descendants).to eq([])
    end
    it "should return all the species" do
      species = create_species genus: @genus
      expect(@genus.species_group_descendants).to eq([species])
    end
    it "should return all the species and subspecies of the genus" do
      species = create_species genus: @genus
      subgenus = create_subgenus genus: @genus
      subspecies = create_subspecies genus: @genus, species: species
      expect(@genus.species_group_descendants).to match_array([species, subspecies])
    end
  end

  describe "Parent" do
    it "should be nil, if there's no subfamily" do
      genus = create_genus subfamily: nil, tribe: nil
      expect(genus.parent).to be_nil
    end
    it "should refer to the subfamily, if there is one" do
      subfamily = create_subfamily
      genus = create_genus subfamily: subfamily, tribe: nil
      expect(genus.parent).to eq(subfamily)
    end
    it "should refer to the tribe, if there is one" do
      tribe = create_tribe
      genus = create_genus subfamily: tribe.subfamily, tribe: tribe
      expect(genus.parent).to eq(tribe)
    end
  end

  describe "Assiging the parent" do
    it "should assign to both tribe and subfamily when parent is a tribe" do
      subfamily = create :subfamily
      tribe = create :tribe, subfamily: subfamily
      protonym = create :protonym

      genus = create_genus 'Aneuretus', protonym: protonym

      genus.parent = tribe
      expect(genus.tribe).to eq(tribe)
      expect(genus.subfamily).to eq(subfamily)
    end
  end

  describe "Updating the parent" do
    it "should assign to both tribe and subfamily when parent is a tribe" do
      subfamily = create :subfamily
      tribe = create :tribe, subfamily: subfamily
      protonym = create :protonym
      genus = create_genus 'Aneuretus', protonym: protonym

      genus.update_parent tribe
      expect(genus.tribe).to eq(tribe)
      expect(genus.subfamily).to eq(subfamily)
    end
    it "should assign the subfamily when the tribe is nil, and set the tribe to nil" do
      subfamily = create :subfamily
      tribe = create :tribe, subfamily: subfamily
      genus = create_genus tribe: tribe
      genus.update_parent subfamily
      expect(genus.tribe).to eq(nil)
      expect(genus.subfamily).to eq(subfamily)
    end
    it "should clear both subfamily and tribe when the new parent is nil" do
      subfamily = create :subfamily
      tribe = create :tribe, subfamily: subfamily
      genus = create_genus tribe: tribe
      genus.update_parent nil
      expect(genus.tribe).to eq(nil)
      expect(genus.subfamily).to eq(nil)
    end

    it "should assign the subfamily of its descendants" do
      subfamily = create :subfamily
      tribe = create :tribe, subfamily: subfamily
      new_subfamily = create :subfamily
      new_tribe = create :tribe, subfamily: new_subfamily
      genus = create_genus tribe: tribe
      species = create_species genus: genus
      subspecies = create_subspecies species: species, genus: genus
      # test the initial subfamilies
      expect(genus.subfamily).to eq(subfamily)
      expect(genus.species.first.subfamily).to eq(subfamily)
      expect(genus.subspecies.first.subfamily).to eq(subfamily)
      # test the updated subfamilies
      genus.update_parent new_tribe
      expect(genus.subfamily).to eq(new_subfamily)
      expect(genus.species.first.subfamily).to eq(new_subfamily)
      expect(genus.subspecies.first.subfamily).to eq(new_subfamily)
    end
  end
end