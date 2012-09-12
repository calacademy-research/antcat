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
      subspecies.name.to_s.should == 'Camponotus gilviventris refectus'
      ref = ForwardRefToParentSpecies.first
      ref.fixee.should == subspecies
      ref.genus.should == genus
      ref.epithet.should == 'gilviventris'
    end

    describe "When the protonym has a different species" do
      describe "Currently subspecies of:" do
        it "should insert the species from the 'Currently subspecies of' history item" do
          genus = create_genus 'Camponotus'
          create_species 'Camponotus hova'
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
          Subspecies.find(subspecies).name.to_s.should == 'Camponotus hova radamae'
        end
        it "should import a subspecies that has a species protonym" do
          genus = create_genus 'Acromyrmex'
          subspecies = Species.import(
            genus:                  genus,
            species_group_epithet:  'boliviensis',
            protonym: {
              genus_name:           'Acromyrmex',
              species_epithet:      'boliviensis',
            },
            raw_history: [{currently_subspecies_of: {species: {species_epithet: 'lundii'}}}]
          )
          subspecies = Subspecies.find subspecies
          subspecies.name.to_s.should == 'Acromyrmex lundii boliviensis'
        end
        it "if it's already a subspecies, don't just keep adding on to its epithets, but replace the middle one(s)" do
          genus = create_genus 'Crematogaster'
          create_species 'Crematogaster jehovae'
          subspecies = Species.import(
            genus:                  genus,
            species_group_epithet:  'mosis',
            protonym: {
              genus_name:           'Camponotus',
              species_epithet:      'auberti',
              subspecies: [{type:   'var.', subspecies_epithet: 'mosis'}]
            },
            raw_history: [{currently_subspecies_of: {species: {species_epithet: 'jehovae'}}}]
          )
          Subspecies.find(subspecies).name.to_s.should == 'Crematogaster jehovae mosis'
        end
      end

      it "should insert the species from the 'Revived from synonymy as subspecies of' history item" do
        genus = create_genus 'Crematogaster'
        create_species 'Crematogaster castanea'

        subspecies = Species.import(
          genus:                  genus,
          species_group_epithet:  'mediorufa',
          protonym: {
            genus_name:           'Crematogaster',
            species_epithet:      'tricolor',
            subspecies: [{type:   'var.', subspecies_epithet: 'mediorufa'}]
          },
          raw_history: [{revived_from_synonymy: {subspecies_of: {species_epithet: 'castanea'}}}],
        )
        Subspecies.find(subspecies).name.to_s.should == 'Crematogaster castanea mediorufa'
      end
    end

    it "should use the right epithet when the protonym differs" do
      subspecies = Species.import(
        species_group_epithet:  'brunneus',
        protonym: { genus_name: 'Aenictus',
          species_epithet:      'soudanicus',
          subspecies: [{type:   'var.', subspecies_epithet: 'brunnea'}]
        },
        genus: @genus,
      )
      subspecies.name.epithet.should == 'brunneus'
    end

  end
end
