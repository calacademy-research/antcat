require 'spec_helper'

describe Subfamily do

  it "should have tribes, which are its children" do
    subfamily = create :subfamily, name: create(:name, name: 'Myrmicinae')
    create :tribe, name: create(:name, name: 'Attini'), subfamily: subfamily
    create :tribe, name: create(:name, name: 'Dacetini'), subfamily: subfamily
    expect(subfamily.tribes.map(&:name).map(&:to_s)).to match_array(['Attini', 'Dacetini'])
    expect(subfamily.tribes).to eq(subfamily.children)
  end

  it "should have collective group names" do
    subfamily = create_subfamily
    collective_group_name = create_genus status: 'collective group name', subfamily: subfamily
    create_genus subfamily: subfamily
    expect(subfamily.reload.collective_group_names).to eq([collective_group_name])
  end

  it "should have genera" do
    myrmicinae = create :subfamily, name: create(:name, name: 'Myrmicinae')
    dacetini = create :tribe, name: create(:name, name: 'Dacetini'), subfamily: myrmicinae
    create_genus 'Atta', subfamily: myrmicinae, tribe: create_tribe('Attini', subfamily: myrmicinae)
    create_genus 'Acanthognathus', subfamily: myrmicinae, tribe: dacetini
    expect(myrmicinae.genera.map(&:name).map(&:to_s)).to match_array(['Atta', 'Acanthognathus'])
  end

  it "should have species" do
    subfamily = create :subfamily
    genus = create :genus, subfamily: subfamily
    species = create :species, genus: genus
    expect(subfamily.species.size).to eq(1)
  end

  it "should have subspecies" do
    subfamily = create :subfamily
    genus = create :genus, subfamily: subfamily
    species = create :species, genus: genus
    subspecies = create :subspecies, genus: genus, species: species
    expect(subfamily.subspecies.size).to eq(1)
  end

  describe "Name" do
    it "is just the name" do
      taxon = create :subfamily, name: create(:name, name: 'Dolichoderinae')
      expect(taxon.name.to_s).to eq('Dolichoderinae')
    end
  end

  describe "Label" do
    it "is just the name" do
      taxon = create :subfamily, name: create(:name, name: 'Dolichoderinae')
      expect(taxon.name.to_html).to eq('Dolichoderinae')
    end
  end

  describe "Statistics" do

    it "should handle 0 children" do
      subfamily = create :subfamily
      expect(subfamily.statistics).to eq({})
    end

    it "should handle 1 valid genus" do
      subfamily = create :subfamily
      genus = create :genus, subfamily: subfamily
      expect(subfamily.statistics).to eq({extant: {genera: {'valid' => 1}}})
    end

    it "should handle 1 valid genus and 2 synonyms" do
      subfamily = create :subfamily
      genus = create :genus, subfamily: subfamily
      2.times { create :genus, subfamily: subfamily, status: 'synonym' }
      expect(subfamily.statistics).to eq({extant: {genera: {'valid' => 1, 'synonym' => 2}}})
    end

    it "should handle 1 valid genus with 2 valid species" do
      subfamily = create :subfamily
      genus = create :genus, subfamily: subfamily
      2.times { create :species, genus: genus, subfamily: subfamily }
      expect(subfamily.statistics).to eq({extant: {genera: {'valid' => 1}, species: {'valid' => 2}}})
    end

    it "should handle 1 valid genus with 2 valid species, one of which has a subspecies" do
      subfamily = create :subfamily
      genus = create :genus, subfamily: subfamily
      create :species, genus: genus
      create :subspecies, genus: genus, species: create(:species, genus: genus)
      expect(subfamily.statistics).to eq({extant: {genera: {'valid' => 1}, species: {'valid' => 2}, subspecies: {'valid' => 1}}})
    end

    it "should differentiate between extinct genera, species and subspecies" do
      subfamily = create :subfamily
      genus = create :genus, subfamily: subfamily
      create :genus, subfamily: subfamily, fossil: true
      create :species, genus: genus
      create :species, genus: genus, fossil: true
      create :subspecies, genus: genus, species: create(:species, genus: genus)
      create :subspecies, genus: genus, species: create(:species, genus: genus), fossil: true
      expect(subfamily.statistics).to eq({
        extant: {genera: {'valid' => 1}, species: {'valid' => 3}, subspecies: {'valid' => 1}},
        fossil: {genera: {'valid' => 1}, species: {'valid' => 1}, subspecies: {'valid' => 1}},
      })
    end

    it "should differentiate between extinct genera, species and subspecies" do
      subfamily = create :subfamily
      genus = create :genus, subfamily: subfamily
      create :genus, subfamily: subfamily, fossil: true
      create :species, genus: genus
      create :species, genus: genus, fossil: true
      create :subspecies, genus: genus, species: create(:species, genus: genus)
      create :subspecies, genus: genus, species: create(:species, genus: genus), fossil: true
      expect(subfamily.statistics).to eq({
        extant: {genera: {'valid' => 1}, species: {'valid' => 3}, subspecies: {'valid' => 1}},
        fossil: {genera: {'valid' => 1}, species: {'valid' => 1}, subspecies: {'valid' => 1}},
      })
    end

    it "should count tribes" do
      subfamily = create :subfamily
      tribe = create :tribe, subfamily: subfamily
      expect(subfamily.statistics).to eq({
        extant: {tribes: {'valid' => 1}}
      })
    end

  end


end
