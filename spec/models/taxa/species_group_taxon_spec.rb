require 'spec_helper'

describe SpeciesGroupTaxon do

  it "can have a subfamily" do
    genus = create_genus 'Afropone'
    create :species_group_taxon, name: create(:name, name: 'championi'), genus: genus
    expect(SpeciesGroupTaxon.find_by_name('championi').subfamily).to eq(genus.subfamily)
  end

  it "doesn't have to have a subfamily" do
    expect(create(:species_group_taxon, subfamily: nil)).to be_valid
  end

  it "must have a genus" do
    taxon = FactoryGirl.build :species_group_taxon, genus: nil
    taxon.save(validate: false)
    create :taxon_state, taxon_id: taxon.id

    expect(taxon).not_to be_valid
    genus = create_genus
    taxon.update_attributes genus: genus
    taxon = SpeciesGroupTaxon.find taxon.id
    expect(taxon).to be_valid
    expect(taxon.genus).to eq(genus)
  end

  it "can have a subgenus" do
    subgenus = create_subgenus
    taxon = create :species_group_taxon, subgenus: subgenus
    expect(SpeciesGroupTaxon.find(taxon.id).subgenus).to eq(subgenus)
  end

  it "doesn't have to have a subgenus" do
    sgt = FactoryGirl.build(:species_group_taxon, subgenus: nil)
    create :taxon_state, taxon_id: sgt.id

    expect(sgt).to be_valid
  end

  it "has its subfamily set from its genus" do
    genus = create_genus
    expect(genus.subfamily).not_to be_nil
    taxon = create :species_group_taxon, genus: genus, subfamily: nil
    expect(taxon.subfamily).to eq(genus.subfamily)
  end

end