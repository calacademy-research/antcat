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
    subspecies = create_subspecies 'Atta major colobopsis', species: nil, genus: @genus
    subspecies.subfamily.should == @genus.subfamily
  end

  it "has its genus assigned from its species, if there is one" do
    genus = create_genus
    species = create_species genus: genus
    subspecies = create_subspecies 'Atta major colobopsis', genus: nil, species: species
    subspecies.genus.should == genus
  end

  it "does not have its genus assigned from its species, if there is not one" do
    genus = create_genus
    subspecies = create_subspecies 'Atta major colobopsis', genus: genus, species: nil
    subspecies.genus.should == genus
  end

  describe "Updating the parent" do
    it "should set all the parent fields" do
      subspecies = create_subspecies 'Atta beta kappa'
      species = create_species
      subspecies.update_parent species
      subspecies.species.should == species
      subspecies.genus.should == species.genus
      subspecies.subgenus.should == species.subgenus
      subspecies.subfamily.should == species.subfamily
    end
  end

  describe "Elevating to species" do
    it "should turn the record into a Species" do
      taxon = create_subspecies 'Atta major colobopsis'
      taxon.should be_kind_of Subspecies
      taxon.elevate_to_species
      taxon = Species.find taxon.id
      taxon.should be_kind_of Species
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
      taxon.name.name.should == 'Atta colobopsis'
      taxon.name.name_html.should == '<i>Atta colobopsis</i>'
      taxon.name.epithet.should == 'colobopsis'
      taxon.name.epithet_html.should == '<i>colobopsis</i>'
      taxon.name.epithets.should be_nil
      taxon.name.protonym_html.should == '<i>Atta major colobopsis</i>'
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
      Name.count.should == name_count + 1
    end
    it "should find an existing species name, if possible" do
      species = create_species 'Atta major', genus: @genus
      subspecies_name = SubspeciesName.create!({
        name:           'Atta major colobopsis',
        name_html:      '<i>Atta major colobopsis</i>',
        epithet:        'colobopsis',
        epithet_html:   '<i>colobopsis</i>',
        epithets:       'major colobopsis',
        protonym_html:  '<i>Atta major colobopsis</i>',
      })
      species_name = SpeciesName.create!({
        name:           'Atta colobopsis',
        name_html:      '<i>Atta colobopsis</i>',
        epithet:        'colobopsis',
        epithet_html:   '<i>colobopsis</i>',
        epithets:       nil,
        protonym_html:  '<i>Atta major colobopsis</i>',
      })
      taxon = create_subspecies name: subspecies_name, genus: @genus, species: species
      taxon.elevate_to_species
      taxon = Species.find taxon.id
      taxon.name.should == species_name
    end
    it "should crash and burn if the species already exists" do
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
      -> {taxon.elevate_to_species}.should raise_error
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
      subspecies.species.should_not == species
      subspecies.fix_missing_species
      subspecies.species.should == species
    end
    it "should find the species that's the first word of epithets when there's more than one subspecies epithet" do
      species = create_species 'Atta major', genus: @genus
      name = FactoryGirl.create :subspecies_name, name: "Atta major minor minimus", epithets: 'major minor minimus'
      subspecies = FactoryGirl.create :subspecies, name: name, species: nil, genus: @genus
      subspecies.species.should_not == species
      subspecies.fix_missing_species
      subspecies.reload.species.should == species
    end
    it "should not croak if the species can't be found" do
      name = FactoryGirl.create :subspecies_name, name: "Atta blanco negro", epithets: 'blanco negro'
      subspecies = FactoryGirl.create :subspecies, name: name, species: nil, genus: @genus
      subspecies.fix_missing_species
      subspecies.reload.species.should be_nil
    end
    it "should not find a species in a different genus" do
      different_genus = create_genus 'Eciton'
      species = create_species 'Atta major', genus: different_genus
      name = FactoryGirl.create :subspecies_name, name: "Atta major minor", epithets: 'major minor'
      subspecies = FactoryGirl.create :subspecies, name: name, species: nil, genus: @genus
      subspecies.fix_missing_species
      subspecies.species.should be_nil
    end
    it "should find a species with a different ending" do
      species = create_species 'Atta perversus', genus: @genus
      name = FactoryGirl.create :subspecies_name, name: 'Atta perversa minor', epithets: 'perversa minor'
      subspecies = FactoryGirl.create :subspecies, name: name, species: nil, genus: @genus
      subspecies.fix_missing_species
      subspecies.species.should == species
    end
  end

  describe "Importing" do
    before do
      @reference = FactoryGirl.create :article_reference, bolton_key_cache: 'Latreille 1809'
    end
    it "should create the subspecies and the forward ref" do
      genus = create_genus 'Camponotus'
      subspecies = Subspecies.import(
        genus:                  genus,
        species_group_epithet:  'refectus',
        protonym: {
          authorship:           [{author_names: ["Latreille"], year: "1809", pages: "124"}],
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
              authorship:           [{author_names: ["Latreille"], year: "1809", pages: "124"}],
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
              authorship:           [{author_names: ["Latreille"], year: "1809", pages: "124"}],
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
              authorship:           [{author_names: ["Latreille"], year: "1809", pages: "124"}],
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
            authorship:           [{author_names: ["Latreille"], year: "1809", pages: "124"}],
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
        protonym: {
          genus_name:           'Aenictus',
          authorship:           [{author_names: ["Latreille"], year: "1809", pages: "124"}],
          species_epithet:      'soudanicus',
          subspecies: [{type:   'var.', subspecies_epithet: 'brunnea'}]
        },
        genus: @genus,
      )
      subspecies.name.epithet.should == 'brunneus'
    end

  end

  describe "Updating" do
    before do
      @reference = FactoryGirl.create :article_reference, bolton_key_cache: 'Latreille 1809'
    end
    it "when updating, should use the the subspecies" do
      genus = create_genus 'Camponotus'
      data = {
        genus:                  genus,
        species_group_epithet:  'refectus',
        history:                [],
        protonym: {
          authorship:           [{author_names: ["Latreille"], year: "1809", pages: "124"}],
          genus_name:           'Camponotus',
          subgenus_epithet:     'Myrmeurynota',
          species_epithet:      'gilviventris',
          subspecies: [{type:   'var.',
            subspecies_epithet: 'refectus'}]}}
      subspecies = Subspecies.import data
      subspecies = Subspecies.find subspecies
      subspecies.name.to_s.should == 'Camponotus gilviventris refectus'

      updated_subspecies = Subspecies.import data
      updated_subspecies.should == subspecies
    end

    it "should handle variants" do
      subspecies = create_subspecies 'Philidris cordata protensa'
      subspecies.protonym.authorship.update_attribute :reference, @reference
      data = {
        :genus => create_genus('Philidris'),
        :species_group_epithet=>"protensa",
        :protonym=>
          {:genus_name=>"Iridomyrmex",
          :species_epithet=>"cordatus",
          :subspecies=>[{:subspecies_epithet=>"protensus", :type=>"subsp."}],
          :authorship=>
            [{:author_names=>["Latreille"], :year=>"1809", :pages=>"47",}],
          :locality=>"Borneo"},
        :history=>[]
          }
      subspecies = Subspecies.import data
      subspecies.name.name.should == 'Philidris cordata protensa'
    end

    it "should delete the species if it looks like the species has been lowered to subspecies" do
      genus = create_genus 'Leptothorax'
      old_species = create_species 'Leptothorax euxanthus', genus: genus
      Taxon.find_by_id(old_species.id).should_not be_blank
      data = {
        genus:                  old_species.genus,
        species_group_epithet:  'euxanthus',
        history:                [],
        protonym: {
          authorship:           [{author_names: ["Latreille"], year: "1809", pages: "124"}],
          genus_name:           'Leptothorax',
          species_epithet:      'nylanderi',
          subspecies: [{type:   'form', subspecies_epithet: 'euxanthus'}]
        }
      }
      taxon = Subspecies.import data
      taxon.name.name.should == 'Leptothorax nylanderi euxanthus'
      Taxon.find_by_id(old_species.id).should be_blank
      Update.count.should == 2

      update = Update.find_by_name 'Leptothorax euxanthus'
      update.field_name.should == 'delete'
      update = Update.find_by_name 'Leptothorax nylanderi euxanthus'
      update.field_name.should == 'create'
    end

    it "should not delete the species if it has any other subspecies" do
      genus = create_genus 'Leptothorax'
      old_species = create_species 'Leptothorax euxanthus', genus: genus
      create_subspecies 'Leptothorax minor major', species: old_species, genus: genus
      data = {
        genus:                  old_species.genus,
        species_group_epithet:  'euxanthus',
        history:                [],
        protonym: {
          authorship:           [{author_names: ["Latreille"], year: "1809", pages: "124"}],
          genus_name:           'Leptothorax',
          species_epithet:      'nylanderi',
          subspecies: [{type:   'form', subspecies_epithet: 'euxanthus'}]
        }
      }
      taxon = Subspecies.import data
      taxon.name.name.should == 'Leptothorax nylanderi euxanthus'
      Taxon.find_by_id(old_species.id).should_not be_blank
      Update.count.should == 1

      update = Update.find_by_name 'Leptothorax nylanderi euxanthus'
      update.field_name.should == 'create'
    end
  end
end
