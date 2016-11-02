require 'spec_helper'

describe Subfamily do
  let(:subfamily) { create :subfamily, name: create(:subfamily_name, name: 'Dolichoderinae') }

  it "can have tribes, which are its children" do
    create :tribe, name: create(:name, name: 'Attini'), subfamily: subfamily
    create :tribe, name: create(:name, name: 'Dacetini'), subfamily: subfamily
    expect(subfamily.tribes.map(&:name).map(&:to_s)).to match_array ['Attini', 'Dacetini']
    expect(subfamily.tribes).to eq subfamily.children
  end

  it "can have collective group names" do
    collective_group_name = create_genus status: 'collective group name', subfamily: subfamily
    create_genus subfamily: subfamily
    expect(subfamily.reload.collective_group_names).to eq [collective_group_name]
  end

  it "can have genera" do
    dacetini = create :tribe, name: create(:name, name: 'Dacetini'), subfamily: subfamily
    create_genus 'Atta', subfamily: subfamily, tribe: create_tribe('Attini', subfamily: subfamily)
    create_genus 'Acanthognathus', subfamily: subfamily, tribe: dacetini
    expect(subfamily.genera.map(&:name).map(&:to_s)).to match_array ['Atta', 'Acanthognathus']
  end

  describe "shared setup" do
    let!(:genus) { create :genus, subfamily: subfamily }
    let!(:species) { create :species, genus: genus }

    it "can have species" do
      expect(subfamily.species.size).to eq 1
    end

    it "can have subspecies" do
      create :subspecies, genus: genus, species: species
      expect(subfamily.subspecies.size).to eq 1
    end
  end

  describe "#name" do
    it "is just the name" do
      expect(subfamily.name.to_s).to eq 'Dolichoderinae'
    end
  end

  # TODO belongs to Name
  describe "Label" do
    it "is just the name" do
      expect(subfamily.name.to_html).to eq 'Dolichoderinae'
    end
  end

  describe "#statistics" do
    it "handles 0 children" do
      expect(subfamily.statistics).to eq({})
    end

    it "handles 1 valid genus" do
      create :genus, subfamily: subfamily
      expect(subfamily.statistics).to eq extant: { genera: { 'valid' => 1 } }
    end

    it "handles 1 valid genus and 2 synonyms" do
      create :genus, subfamily: subfamily
      2.times { create :genus, subfamily: subfamily, status: 'synonym' }

      expect(subfamily.statistics).to eq extant: {
        genera: { 'valid' => 1, 'synonym' => 2}
      }
    end

    it "handles 1 valid genus with 2 valid species" do
      genus = create :genus, subfamily: subfamily
      2.times { create :species, genus: genus, subfamily: subfamily }

      expect(subfamily.statistics).to eq extant: {
        genera: { 'valid' => 1 },
        species: { 'valid' => 2 }
      }
    end

    it "handles 1 valid genus with 2 valid species, one of which has a subspecies" do
      genus = create :genus, subfamily: subfamily
      create :species, genus: genus
      create :subspecies, genus: genus, species: create(:species, genus: genus)

      expect(subfamily.statistics).to eq extant: {
        genera: { 'valid' => 1 },
        species: { 'valid' => 2 },
        subspecies: { 'valid' => 1 }
      }
    end

    it "differentiates between extinct genera, species and subspecies" do
      genus = create :genus, subfamily: subfamily
      create :genus, subfamily: subfamily, fossil: true
      create :species, genus: genus
      create :species, genus: genus, fossil: true
      create :subspecies, genus: genus, species: create(:species, genus: genus)
      create :subspecies, genus: genus, species: create(:species, genus: genus), fossil: true

      expect(subfamily.statistics).to eq(
        extant: {
          genera: { 'valid' => 1 },
          species: { 'valid' => 3 },
          subspecies: { 'valid' => 1 }
        },
        fossil: {
          genera: { 'valid' => 1 },
          species: { 'valid' => 1 },
          subspecies: { 'valid' => 1 }
        }
      )
    end

    it "can count tribes" do
      create :tribe, subfamily: subfamily
      expect(subfamily.statistics).to eq extant: { tribes: { 'valid' => 1 } }
    end
  end
end
