require 'spec_helper'

describe TaxatryHelper do

  describe 'Statistics' do

      it "should format a subfamily's statistics correctly" do
        subfamily = Factory :subfamily
        Factory :genus, :subfamily => subfamily
        Factory :genus, :subfamily => subfamily
        genus = Factory :genus, :subfamily => subfamily, :status => 'synonym'
        2.times {Factory :genus, :subfamily => subfamily, :status => 'homonym'}
        Factory :species, :genus => genus
        helper.taxon_statistics(subfamily).should == "2 valid genera (1 synonym, 2 homonyms), 1 valid species"
      end

      it "should format a genus's statistics correctly" do
        genus = Factory :genus
        Factory :species, :genus => genus
        helper.taxon_statistics(genus).should == "1 valid species"
      end

      it "should format a species's statistics correctly" do
        species = Factory :species
        Factory :subspecies, :species => species
        helper.taxon_statistics(species).should == "1 valid subspecies"
      end

      it "should not pluralize certain statuses" do
        genus = Factory :genus
        2.times {Factory :species, :genus => genus, :status => 'valid'}
        2.times {Factory :species, :genus => genus, :status => 'synonym'}
        2.times {Factory :species, :genus => genus, :status => 'homonym'}
        2.times {Factory :species, :genus => genus, :status => 'unavailable'}
        2.times {Factory :species, :genus => genus, :status => 'unidentifiable'}
        2.times {Factory :species, :genus => genus, :status => 'excluded'}
        2.times {Factory :species, :genus => genus, :status => 'unresolved homonym'}
        2.times {Factory :species, :genus => genus, :status => 'nomen nudum'}
        helper.taxon_statistics(genus).should == "2 valid species (2 synonyms, 2 homonyms, 2 unavailable, 2 unidentifiable, 2 excluded, 2 unresolved homonyms, 2 nomina nuda)"
      end

    end
end
