# coding: UTF-8
require 'spec_helper'

describe Subspecies do
  before do
    @genus = create_genus 'Atta'
  end

  it "has no statistics" do
    Subspecies.new.statistics.should be_nil
  end

  it "does not have to have a species (before being fixed up, e.g.)" do
    subspecies = create_subspecies 'Atta major colobopsis', genus: @genus, species: nil
    subspecies.should be_valid
  end

  it "must have a genus" do
    subspecies = create_subspecies 'Atta major colobopsis', genus: nil, species: nil, build: true
    subspecies.should_not be_valid
  end

  it "has its subfamily assigned from its genus" do
    subspecies = create_subspecies 'Atta major colobopsis', genus: @genus
    subspecies.subfamily.should == @genus.subfamily
  end

  describe "Importing" do

    it "should create the subspecies and the forward ref" do
      genus = create_genus 'Camponotus'
      subspecies = Subspecies.import(
        genus:                  genus,
        species_group_epithet:  'refectus',
        protonym: {
          genus_name:           'Camponotus',
          subgenus_epithet:     'Myrmeurynota',
          species_epithet:      'gilviventris',
          subspecies: [{type:   'var.',
            subspecies_epithet: 'refectus',
        }]})
      subspecies = Subspecies.find subspecies
      subspecies.name.to_s.should == 'Camponotus (Myrmeurynota) gilviventris var. refectus'
      ref = SpeciesForwardRef.first
      ref.fixee.should == subspecies
      ref.genus.should == genus
      ref.epithet.should == 'gilviventris'
    end

    it "should import a subspecies that has a subspecies protonym for a different species than current" do
      genus = create_genus 'Camponotus'
      species_name = FactoryGirl.create :species_name, name: 'Camponotus hova', epithet: 'hova'
      species = create_species name: species_name, genus: genus

      subspecies = Species.import(
        genus:                  genus,
        species_group_epithet:  'radamae',
        protonym: {
          genus_name:           'Camponotus',
          species_epithet:      'maculatus',
          subspecies: [{type:   'r.', subspecies_epithet: 'radamae'}]
        },
        raw_history: [{currently_subspecies_of: {species: {species_epithet: 'hova'}}}]
      )
      subspecies = Subspecies.find subspecies
      subspecies.name.to_s.should == 'Camponotus maculatus r. radamae'
      ref = SpeciesForwardRef.first
      ref.fixee.should == subspecies
      ref.genus.should == genus
      ref.epithet.should == 'hova'
    end
  end

end
