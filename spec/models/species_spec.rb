# coding: UTF-8
require 'spec_helper'

describe Species do

  it "should have subspecies, which are its children" do
    species = create_species 'Atta chilensis'
    create_subspecies 'Atta chilensis robusta', species: species
    create_subspecies 'Atta chilensis saltensis', species: species
    species = Species.find_by_name 'Atta chilensis'
    species.subspecies.map(&:name).map(&:epithet).should =~ ['robusta', 'saltensis']
    species.children.should == species.subspecies
  end

  describe "Statistics" do
    it "should handle 0 children" do
      create_species.statistics.should == {}
    end
    it "should handle 1 valid subspecies" do
      species = create_species
      subspecies = create_subspecies species: species
      species.statistics.should == {extant: {subspecies: {'valid' => 1}}}
    end
    it "should differentiate between extant and fossil subspecies" do
      species = create_species
      subspecies = create_subspecies species: species
      create_subspecies species: species, fossil: true
      species.statistics.should == {
        extant: {subspecies: {'valid' => 1}},
        fossil: {subspecies: {'valid' => 1}},
      }
    end
    it "should differentiate between extant and fossil subspecies" do
      species = create_species
      subspecies = create_subspecies species: species
      create_subspecies species: species, fossil: true
      species.statistics.should == {
        extant: {subspecies: {'valid' => 1}},
        fossil: {subspecies: {'valid' => 1}},
      }
    end
    it "should handle 1 valid subspecies and 2 synonyms" do
      species = create_species
      create_subspecies species: species
      2.times {create_subspecies species: species, status: 'synonym'}
      species.statistics.should == {extant: {subspecies: {'valid' => 1, 'synonym' => 2}}}
    end

  end

  describe "Siblings" do
    it "should return itself and its genus's species" do
      create_species
      genus = create_genus
      species = create_species genus: genus
      another_species = create_species genus: genus
      species.siblings.should =~ [species, another_species]
    end
  end

  describe "Importing" do
    it "should import a species" do
      subfamily = create_subfamily
      genus = create_genus 'Fiona', subfamily: subfamily
      reference = FactoryGirl.create :article_reference, bolton_key_cache: 'Latreille 1809'

      species = Species.import(
        genus: genus,
        species_epithet: 'major',
        fossil: true,
        protonym: {genus_name: "Atta", species_epithet: 'major',
                   authorship: [{author_names: ["Latreille"], year: "1809", pages: "124"}]},
        history: ['Atta major as species', 'Atta major as subspecies']
      )
      species = Species.find species
      species.name.to_s.should == 'Fiona major'
      species.should_not be_invalid
      species.should be_fossil
      species.genus.should == genus
      species.subfamily.should == subfamily
      species.taxonomic_history_items.map(&:taxt).should == ['Atta major as species', 'Atta major as subspecies']

      protonym = species.protonym
      protonym.name.to_s.should == 'Atta major'

      authorship = protonym.authorship
      authorship.pages.should == '124'

      authorship.reference.should == reference
    end

    describe "Importing species that look like subspecies" do
      it "should import a species with a subspecies protonym and a list of subspecies" do
        genus = create_genus 'Aenictus'
        taxon = Species.import(
          genus:                  genus,
          species_group_epithet:  'alluaudi',
          protonym: {
            genus_name:           'Aenictus',
            species_epithet:      'bottegoi',
            subspecies: [{type:   'var.',
              subspecies_epithet: 'alluaudi',
            }]
          },
          raw_history: [{subspecies: [{species_group_epithet: 'falcifer'}]}],
        )
        taxon.should be_kind_of Species
      end

      it "should import a species with a subspecies protonym that was raised to species" do
        genus = create_genus 'Anonychomyrma'
        taxon = Species.import(
          genus:                  genus,
          species_group_epithet:  'malandana',
          protonym: {
            genus_name:           'Iridomyrmex',
            species_epithet:      'innocens',
            subspecies: [{type:   'r.',
              subspecies_epithet: 'malandanus',
            }]
          },
          raw_history: [{raised_to_species: {references:[]}}]
        )
        taxon.should be_kind_of Species
      end

      it "should import a species with a subspecies protonym that has 'raised to species' in the text" do
        genus = create_genus 'Anonychomyrma'
        taxon = Species.import(
          genus:                  genus,
          species_group_epithet:  'malandana',
          protonym: {
            genus_name:           'Iridomyrmex',
            species_epithet:      'innocens',
            subspecies: [{type:   'r.',
              subspecies_epithet: 'malandanus',
            }]
          },
          raw_history: [{text: [{phrase:'Raised to species and senior synonym of', delimiter:' '}]}]
        )
        taxon.should be_kind_of Species
      end

    end
  end

end
