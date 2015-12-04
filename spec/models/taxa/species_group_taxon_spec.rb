# coding: UTF-8
require 'spec_helper'

describe SpeciesGroupTaxon do

  it "can have a subfamily" do
    genus = create_genus 'Afropone'
    FactoryGirl.create :species_group_taxon, name: FactoryGirl.create(:name, name: 'championi'), genus: genus
    expect(SpeciesGroupTaxon.find_by_name('championi').subfamily).to eq(genus.subfamily)
  end

  it "doesn't have to have a subfamily" do
    expect(FactoryGirl.create(:species_group_taxon, subfamily: nil)).to be_valid
  end

  it "must have a genus" do
    taxon = FactoryGirl.build :species_group_taxon, genus: nil
    taxon.save(:validate => false)
    FactoryGirl.create :taxon_state, taxon_id: taxon.id

    expect(taxon).not_to be_valid
    genus = create_genus
    taxon.update_attributes genus: genus
    taxon = SpeciesGroupTaxon.find taxon.id
    expect(taxon).to be_valid
    expect(taxon.genus).to eq(genus)
  end

  it "can have a subgenus" do
    subgenus = create_subgenus
    taxon = FactoryGirl.create :species_group_taxon, subgenus: subgenus
    expect(SpeciesGroupTaxon.find(taxon.id).subgenus).to eq(subgenus)
  end

  it "doesn't have to have a subgenus" do
    sgt = FactoryGirl.build(:species_group_taxon, subgenus: nil)
    FactoryGirl.create :taxon_state, taxon_id: sgt.id

    expect(sgt).to be_valid
  end

  it "has its subfamily set from its genus" do
    genus = create_genus
    expect(genus.subfamily).not_to be_nil
    taxon = FactoryGirl.create :species_group_taxon, genus: genus, subfamily: nil
    expect(taxon.subfamily).to eq(genus.subfamily)
  end

  describe "Picking the validest " do
    it "should return nil if there is none" do
      targets = []
      expect(SpeciesGroupTaxon.pick_validest(targets)).to be_nil
    end

    it "should return nil if there is none" do
      targets = nil
      expect(SpeciesGroupTaxon.pick_validest(targets)).to be_nil
    end

    it "should pick the best target, if there is more than one" do
      invalid_species = create_species status: 'homonym'
      valid_species = create_species status: 'valid'
      targets = [invalid_species, valid_species]
      expect(SpeciesGroupTaxon.pick_validest(targets)).to eq([valid_species])
    end

    it "should return all the targets if there's no clear choice" do
      valid_species = create_species 'Atta major'
      another_valid_species = create_species 'Atta minor'
      targets = [another_valid_species, valid_species]
      expect(SpeciesGroupTaxon.pick_validest(targets)).to match_array([valid_species, another_valid_species])
    end

    it "should not pick the homonym, no matter what" do
      homonym_species = create_species status: 'homonym'
      targets = [homonym_species]
      expect(SpeciesGroupTaxon.pick_validest(targets)).to be_nil
    end

  end
end