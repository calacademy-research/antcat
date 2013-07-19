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

  describe "Versioning" do
    it "should record versions" do
      with_versioning do
        taxon = create_genus
        taxon.versions.last.event.should == 'create'
      end
    end
    it "should record the changes" do
      with_versioning do
        genus = create_genus
        genus.update_attributes! status: 'synonym'
        genus.versions(true).last.changeset.should == {'status' => ['valid', 'synonym']}
      end
    end
  end

end
