# coding: UTF-8
require 'spec_helper'

describe Subspecies do
  before do
    @genus = create_genus 'Atta'
  end

  it "has no statistics" do
    expect(Subspecies.new.statistics).to be_nil
  end

  it "does not have to have a species (before being fixed up, e.g.)" do
    subspecies = create_subspecies 'Atta major colobopsis', genus: @genus, species: nil
    expect(subspecies).to be_valid
  end

  it "must have a genus" do
    subspecies = create_subspecies 'Atta major colobopsis', genus: nil, species: nil, build: true
    FactoryGirl.create :taxon_state, taxon_id: subspecies.id

    expect(subspecies).not_to be_valid
  end

  it "has its subfamily assigned from its genus" do
    subspecies = create_subspecies 'Atta major colobopsis', species: nil, genus: @genus
    expect(subspecies.subfamily).to eq(@genus.subfamily)
  end

  it "has its genus assigned from its species, if there is one" do
    genus = create_genus
    species = create_species genus: genus
    subspecies = create_subspecies 'Atta major colobopsis', genus: nil, species: species
    expect(subspecies.genus).to eq(genus)
  end

  it "does not have its genus assigned from its species, if there is not one" do
    genus = create_genus
    subspecies = create_subspecies 'Atta major colobopsis', genus: genus, species: nil
    expect(subspecies.genus).to eq(genus)
  end

  describe "Updating the parent" do
    it "should set all the parent fields" do
      subspecies = create_subspecies 'Atta beta kappa'
      species = create_species
      subspecies.update_parent species
      expect(subspecies.species).to eq(species)
      expect(subspecies.genus).to eq(species.genus)
      expect(subspecies.subgenus).to eq(species.subgenus)
      expect(subspecies.subfamily).to eq(species.subfamily)
    end
  end

  describe "The genus is the parent if there's no species" do
    it "should return the genus" do
      genus = create_genus
      taxon = create_subspecies genus: genus, species: nil
      expect(taxon.parent).to eq(genus)
    end
  end

  describe "Elevating to species" do
    it "should turn the record into a Species" do
      taxon = create_subspecies 'Atta major colobopsis'
      expect(taxon).to be_kind_of Subspecies
      taxon.elevate_to_species
      taxon = Species.find taxon.id
      expect(taxon).to be_kind_of Species
    end
    it "should form the new species name from the epithet" do
      species = create_species 'Atta major', genus: @genus
      subspecies_name = SubspeciesName.create!({
        name:           'Atta major colobopsis',
        name_html:      '<i>Atta major colobopsis</i>',
        epithet:        'colobopsis',
        epithet_html:   '<i>colobopsis</i>',
        epithets:       'major colobopsis',
        protonym_html:  '<i>Atta major colobopsis</i>',
      })
      taxon = create_subspecies name: subspecies_name, genus: @genus, species: species
      taxon.elevate_to_species
      taxon = Species.find taxon.id
      expect(taxon.name.name).to eq('Atta colobopsis')
      expect(taxon.name.name_html).to eq('<i>Atta colobopsis</i>')
      expect(taxon.name.epithet).to eq('colobopsis')
      expect(taxon.name.epithet_html).to eq('<i>colobopsis</i>')
      expect(taxon.name.epithets).to be_nil
    end
    it "should create the new species name, if necessary" do
      species = create_species 'Atta major', genus: @genus
      subspecies_name = SubspeciesName.create!({
        name:           'Atta major colobopsis',
        name_html:      '<i>Atta major colobopsis</i>',
        epithet:        'colobopsis',
        epithet_html:   '<i>colobopsis</i>',
        epithets:       'major colobopsis',
        protonym_html:  '<i>Atta major colobopsis</i>',
      })
      taxon = create_subspecies name: subspecies_name, genus: @genus, species: species
      name_count = Name.count
      taxon.elevate_to_species
      expect(Name.count).to eq(name_count + 1)
    end
    it "should find an existing species name, if possible" do
      species = create_species 'Atta colobopsis', genus: @genus
      subspecies_name = SubspeciesName.create!({
        name:           'Atta major colobopsis',
        name_html:      '<i>Atta major colobopsis</i>',
        epithet:        'colobopsis',
        epithet_html:   '<i>colobopsis</i>',
        epithets:       'major colobopsis',
        protonym_html:  '<i>Atta major colobopsis</i>',
      })
      taxon = create_subspecies name: subspecies_name, genus: @genus, species: species
      taxon.elevate_to_species
      taxon = Species.find taxon.id
      expect(taxon.name).to eq(species.name)
    end
    it "should not crash and burn if the species already exists" do
      species = create_species 'Atta major', genus: @genus
      subspecies_name = SubspeciesName.create!({
        name:           'Atta batta major',
        name_html:      '<i>Atta batta major</i>',
        epithet:        'major',
        epithet_html:   '<i>major</i>',
        epithets:       'batta major',
        protonym_html:  '<i>Atta batta major</i>',
      })
      taxon = create_subspecies name: subspecies_name, species: species
      expect {taxon.elevate_to_species}.not_to raise_error
    end
  end

  describe "Fixing subspecies without species" do
    before do
      @genus = create_genus 'Atta'
    end
    it "should find the species that's the first word of epithets in same genus" do
      species = create_species 'Atta major', genus: @genus
      name = FactoryGirl.create :subspecies_name, name: "Atta major minor", epithets: 'major minor'
      subspecies = FactoryGirl.create :subspecies, name: name, species: nil, genus: @genus
      expect(subspecies.species).not_to eq(species)
      subspecies.fix_missing_species
      expect(subspecies.species).to eq(species)
    end
    it "should find the species that's the first word of epithets when there's more than one subspecies epithet" do
      species = create_species 'Atta major', genus: @genus
      name = FactoryGirl.create :subspecies_name, name: "Atta major minor minimus", epithets: 'major minor minimus'
      subspecies = FactoryGirl.create :subspecies, name: name, species: nil, genus: @genus
      expect(subspecies.species).not_to eq(species)
      subspecies.fix_missing_species
      expect(subspecies.reload.species).to eq(species)
    end
    it "should not croak if the species can't be found" do
      name = FactoryGirl.create :subspecies_name, name: "Atta blanco negro", epithets: 'blanco negro'
      subspecies = FactoryGirl.create :subspecies, name: name, species: nil, genus: @genus
      subspecies.fix_missing_species
      expect(subspecies.reload.species).to be_nil
    end
    it "should not find a species in a different genus" do
      different_genus = create_genus 'Eciton'
      species = create_species 'Atta major', genus: different_genus
      name = FactoryGirl.create :subspecies_name, name: "Atta major minor", epithets: 'major minor'
      subspecies = FactoryGirl.create :subspecies, name: name, species: nil, genus: @genus
      subspecies.fix_missing_species
      expect(subspecies.species).to be_nil
    end
    it "should find a species with a different ending" do
      species = create_species 'Atta perversus', genus: @genus
      name = FactoryGirl.create :subspecies_name, name: 'Atta perversa minor', epithets: 'perversa minor'
      subspecies = FactoryGirl.create :subspecies, name: name, species: nil, genus: @genus
      subspecies.fix_missing_species
      expect(subspecies.species).to eq(species)
    end
  end

end