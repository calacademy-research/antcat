# coding: UTF-8
require 'spec_helper'

describe Taxon do

  describe "Import synonyms" do
    it "should create a new synonym if it doesn't exist" do
      senior = create_genus
      junior = create_genus
      junior.import_synonyms senior
      Synonym.count.should == 1
      synonym = Synonym.first
      synonym.junior_synonym.should == junior
      synonym.senior_synonym.should == senior
    end
    it "should not create a new synonym if it exists" do
      senior = create_genus
      junior = create_genus
      Synonym.create! junior_synonym: junior, senior_synonym: senior
      Synonym.count.should == 1

      junior.import_synonyms senior
      Synonym.count.should == 1
      synonym = Synonym.first
      synonym.junior_synonym.should == junior
      synonym.senior_synonym.should == senior
    end
    it "should not try to create a synonym if the senior is nil" do
      senior = nil
      junior = create_genus
      junior.import_synonyms senior
      Synonym.count.should be_zero
    end
  end

  describe "Extracting original combinations" do
    it "should create an 'original combination' taxon when genus doesn't match protonym's genus" do
      nylanderia = create_genus 'Nylanderia'
      paratrechina = create_genus 'Paratrechina'

      recombined_protonym = FactoryGirl.create :protonym, name: create_species_name('Paratrechina minutula')
      recombined = create_species 'Nylanderia minutula', genus: nylanderia, protonym: recombined_protonym

      not_recombined_protonym = FactoryGirl.create :protonym, name: create_species_name('Nylanderia illustra')
      not_recombined = create_species 'Nylanderia illustra', genus: nylanderia, protonym: not_recombined_protonym

      taxon_count = Taxon.count

      Taxon.extract_original_combinations

      Taxon.count.should == taxon_count + 1
      original_combinations = Taxon.where status: 'original combination'
      original_combinations.size.should == 1
      original_combination = original_combinations.first
      original_combination.genus.should == paratrechina
      original_combination.current_valid_taxon.should == recombined
    end
  end

  describe "Setting current valid taxon to the senior synonym" do
    it "should not worry if the field is already populated" do
      senior = create_genus
      current_valid_taxon = create_genus
      taxon = create_synonym senior, current_valid_taxon: current_valid_taxon
      taxon.update_current_valid_taxon
      taxon.current_valid_taxon.should == current_valid_taxon
    end
    it "should find the latest senior synonym" do
      senior = create_genus
      taxon = create_synonym senior
      taxon.update_current_valid_taxon
      taxon.current_valid_taxon.should == senior
    end
    it "should find the latest senior synonym that's valid" do
      senior = create_genus
      invalid_senior = create_genus status: 'homonym'
      taxon = create_synonym invalid_senior
      Synonym.create! senior_synonym: senior, junior_synonym: taxon
      taxon.update_current_valid_taxon
      taxon.current_valid_taxon.should == senior
    end
    it "should handle when none are valid, in preparation for a Vlad run" do
      invalid_senior = create_genus status: 'homonym'
      another_invalid_senior = create_genus status: 'homonym'
      taxon = create_synonym invalid_senior
      Synonym.create! senior_synonym: another_invalid_senior, junior_synonym: taxon
      taxon.update_current_valid_taxon
      taxon.current_valid_taxon.should be_nil
    end
    it "should handle when there's a synonym of a synonym" do

      senior_synonym = create_genus
      synonym = create_genus status: 'synonym'
      Synonym.create! junior_synonym: synonym, senior_synonym: senior_synonym

      synonym_of_synonym = create_genus status: 'synonym'
      Synonym.create! junior_synonym: synonym_of_synonym, senior_synonym: synonym

      synonym.update_current_valid_taxon
      synonym.current_valid_taxon.should == senior_synonym
    end
  end

  describe "Using location to update biogeographic region" do
    def make_map pair
      #{a: :b} -> a: {biogeographic_region: :b, used_count: 0}
      hash = {}
      hash[pair.keys.first] = {biogeographic_region: pair.values.first, used_count: 0}
      hash
    end
    it "should do nothing if there's no replacement defined" do
      protonym = FactoryGirl.create :protonym, locality: 'San Pedro'
      taxon = create_genus protonym: protonym
      taxon.update_biogeographic_region_from_locality make_map 'CAPETOWN' => 'Africa'
      taxon.biogeographic_region.should be_nil
    end
    it "should do the replacement if there's a replacement defined" do
      protonym = FactoryGirl.create :protonym, locality: 'San Pedro'
      taxon = create_genus protonym: protonym
      taxon.update_biogeographic_region_from_locality make_map 'SAN PEDRO' => 'Africa'
      taxon.biogeographic_region.should == 'Africa'
    end
    it "should not do the replacement if it's a fossil taxon" do
      protonym = FactoryGirl.create :protonym, locality: 'San Pedro'
      taxon = create_genus protonym: protonym, fossil: true
      taxon.update_biogeographic_region_from_locality make_map 'SAN PEDRO' => 'Africa'
      taxon.biogeographic_region.should be_nil
    end
    it "should be case-insensitive" do
      protonym = FactoryGirl.create :protonym, locality: 'San Pedro'
      taxon = create_genus protonym: protonym
      taxon.update_biogeographic_region_from_locality make_map 'SAN PEDRO' => 'Africa'
      taxon.biogeographic_region.should == 'Africa'
    end
    it "should treat 'none' as nil" do
      protonym = FactoryGirl.create :protonym, locality: 'San Pedro'
      taxon = create_genus protonym: protonym
      taxon.update_biogeographic_region_from_locality make_map 'SAN PEDRO' => 'none'
      taxon.biogeographic_region.should be_nil
    end
  end

  describe "Reporting" do
    it "should show which localities in Flávia's document weren't used" do
      File.stub(:open).and_return "America 3\tNuevo\n"
      Taxon.biogeographic_regions_for_localities.should == {'AMERICA' => {biogeographic_region: 'Nuevo', used_count: 0}}
    end
    it "should not show taxa which were used" do
      protonym = FactoryGirl.create :protonym, locality: 'America'
      taxon = create_genus protonym: protonym
      File.stub(:open).and_return "America 3\tNuevo\n"
      map = Taxon.biogeographic_regions_for_localities
      taxon.update_biogeographic_region_from_locality map
      map.should == {'AMERICA' => {biogeographic_region: 'Nuevo', used_count: 1}}
    end
  end

  describe "Reading Flávia's document to produce locality-to-biogregion mapping" do
    it "should strip the counts and create a hash" do
      File.stub(:open).and_return "America 3\tNuevo\n"
      Taxon.biogeographic_regions_for_localities.should == {'AMERICA' => {biogeographic_region: 'Nuevo', used_count: 0}}
    end
  end

end
