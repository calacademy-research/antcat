# coding: UTF-8
require 'spec_helper'

describe Subfamily do

  it "should have tribes, which are its children" do
    subfamily = FactoryGirl.create :subfamily, name: FactoryGirl.create(:name, name: 'Myrmicinae')
    FactoryGirl.create :tribe, name: FactoryGirl.create(:name, name: 'Attini'), :subfamily => subfamily
    FactoryGirl.create :tribe, name: FactoryGirl.create(:name, name: 'Dacetini'), :subfamily => subfamily
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
    myrmicinae = FactoryGirl.create :subfamily, name: FactoryGirl.create(:name, name: 'Myrmicinae')
    dacetini = FactoryGirl.create :tribe, name: FactoryGirl.create(:name, name: 'Dacetini'), subfamily: myrmicinae
    create_genus 'Atta', subfamily: myrmicinae, tribe: create_tribe('Attini', subfamily: myrmicinae)
    create_genus 'Acanthognathus', subfamily: myrmicinae, tribe: dacetini
    expect(myrmicinae.genera.map(&:name).map(&:to_s)).to match_array(['Atta', 'Acanthognathus'])
  end

  it "should have species" do
    subfamily = FactoryGirl.create :subfamily
    genus = FactoryGirl.create :genus, :subfamily => subfamily
    species = FactoryGirl.create :species, :genus => genus
    expect(subfamily.species.size).to eq(1)
  end

  it "should have subspecies" do
    subfamily = FactoryGirl.create :subfamily
    genus = FactoryGirl.create :genus, subfamily: subfamily
    species = FactoryGirl.create :species, genus: genus
    subspecies = FactoryGirl.create :subspecies, genus: genus, species: species
    expect(subfamily.subspecies.size).to eq(1)
  end

  describe "Name" do
    it "is just the name" do
      taxon = FactoryGirl.create :subfamily, name: FactoryGirl.create(:name, name: 'Dolichoderinae')
      expect(taxon.name.to_s).to eq('Dolichoderinae')
    end
  end

  describe "Label" do
    it "is just the name" do
      taxon = FactoryGirl.create :subfamily, name: FactoryGirl.create(:name, name: 'Dolichoderinae')
      expect(taxon.name.to_html).to eq('Dolichoderinae')
    end
  end

  describe "Statistics" do

    it "should handle 0 children" do
      subfamily = FactoryGirl.create :subfamily
      expect(subfamily.statistics).to eq({})
    end

    it "should handle 1 valid genus" do
      subfamily = FactoryGirl.create :subfamily
      genus = FactoryGirl.create :genus, :subfamily => subfamily
      expect(subfamily.statistics).to eq({:extant => {:genera => {'valid' => 1}}})
    end

    it "should handle 1 valid genus and 2 synonyms" do
      subfamily = FactoryGirl.create :subfamily
      genus = FactoryGirl.create :genus, :subfamily => subfamily
      2.times {FactoryGirl.create :genus, :subfamily => subfamily, :status => 'synonym'}
      expect(subfamily.statistics).to eq({:extant => {:genera => {'valid' => 1, 'synonym' => 2}}})
    end

    it "should handle 1 valid genus with 2 valid species" do
      subfamily = FactoryGirl.create :subfamily
      genus = FactoryGirl.create :genus, :subfamily => subfamily
      2.times {FactoryGirl.create :species, :genus => genus, :subfamily => subfamily}
      expect(subfamily.statistics).to eq({:extant => {:genera => {'valid' => 1}, :species => {'valid' => 2}}})
    end

    it "should handle 1 valid genus with 2 valid species, one of which has a subspecies" do
      subfamily = FactoryGirl.create :subfamily
      genus = FactoryGirl.create :genus, :subfamily => subfamily
      FactoryGirl.create :species, genus: genus
      FactoryGirl.create :subspecies, genus: genus, species: FactoryGirl.create(:species, genus: genus)
      expect(subfamily.statistics).to eq({extant: {genera: {'valid' => 1}, species: {'valid' => 2}, subspecies: {'valid' => 1}}})
    end

    it "should differentiate between extinct genera, species and subspecies" do
      subfamily = FactoryGirl.create :subfamily
      genus = FactoryGirl.create :genus, subfamily: subfamily
      FactoryGirl.create :genus, subfamily: subfamily, fossil: true
      FactoryGirl.create :species, genus: genus
      FactoryGirl.create :species, genus: genus, fossil: true
      FactoryGirl.create :subspecies, genus: genus, species: FactoryGirl.create(:species, genus: genus)
      FactoryGirl.create :subspecies, genus: genus, species: FactoryGirl.create(:species, genus: genus), fossil: true
      expect(subfamily.statistics).to eq({
        extant: {genera: {'valid' => 1}, species: {'valid' => 3}, subspecies: {'valid' => 1}},
        :fossil => {genera: {'valid' => 1}, species: {'valid' => 1}, subspecies: {'valid' => 1}},
      })
    end

    it "should differentiate between extinct genera, species and subspecies" do
      subfamily = FactoryGirl.create :subfamily
      genus = FactoryGirl.create :genus, subfamily: subfamily
      FactoryGirl.create :genus, subfamily: subfamily, fossil: true
      FactoryGirl.create :species, genus: genus
      FactoryGirl.create :species, genus: genus, fossil: true
      FactoryGirl.create :subspecies, genus: genus, species: FactoryGirl.create(:species, genus: genus)
      FactoryGirl.create :subspecies, genus: genus, species: FactoryGirl.create(:species, genus: genus), fossil: true
      expect(subfamily.statistics).to eq({
        extant: {genera: {'valid' => 1}, species: {'valid' => 3}, subspecies: {'valid' => 1}},
        fossil: {genera: {'valid' => 1}, species: {'valid' => 1}, subspecies: {'valid' => 1}},
      })
    end

    it "should count tribes" do
      subfamily = FactoryGirl.create :subfamily
      tribe = FactoryGirl.create :tribe, subfamily: subfamily
      expect(subfamily.statistics).to eq({
        extant: {tribes: {'valid' => 1}}
      })
    end

  end


end
