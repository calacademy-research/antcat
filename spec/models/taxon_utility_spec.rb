# coding: UTF-8
require 'spec_helper'

describe Taxon do

  describe "Import synonyms" do
    it "should create a new synonym if it doesn't exist" do
      senior = create_genus
      junior = create_genus
      junior.import_synonyms senior
      expect(Synonym.count).to eq(1)
      synonym = Synonym.first
      expect(synonym.junior_synonym).to eq(junior)
      expect(synonym.senior_synonym).to eq(senior)
    end
    it "should not create a new synonym if it exists" do
      senior = create_genus
      junior = create_genus
      Synonym.create! junior_synonym: junior, senior_synonym: senior
      expect(Synonym.count).to eq(1)

      junior.import_synonyms senior
      expect(Synonym.count).to eq(1)
      synonym = Synonym.first
      expect(synonym.junior_synonym).to eq(junior)
      expect(synonym.senior_synonym).to eq(senior)
    end
    it "should not try to create a synonym if the senior is nil" do
      senior = nil
      junior = create_genus
      junior.import_synonyms senior
      expect(Synonym.count).to be_zero
    end
  end



  describe "Setting current valid taxon to the senior synonym" do
    it "should not worry if the field is already populated" do
      senior = create_genus
      current_valid_taxon = create_genus
      taxon = create_synonym senior, current_valid_taxon: current_valid_taxon
      taxon.update_current_valid_taxon
      expect(taxon.current_valid_taxon).to eq(current_valid_taxon)
    end
    it "should find the latest senior synonym" do
      senior = create_genus
      taxon = create_synonym senior
      taxon.update_current_valid_taxon
      expect(taxon.current_valid_taxon).to eq(senior)
    end
    it "should find the latest senior synonym that's valid" do
      senior = create_genus
      invalid_senior = create_genus status: 'homonym'
      taxon = create_synonym invalid_senior
      Synonym.create! senior_synonym: senior, junior_synonym: taxon
      taxon.update_current_valid_taxon
      expect(taxon.current_valid_taxon).to eq(senior)
    end
    it "should handle when none are valid, in preparation for a Vlad run" do
      invalid_senior = create_genus status: 'homonym'
      another_invalid_senior = create_genus status: 'homonym'
      taxon = create_synonym invalid_senior
      Synonym.create! senior_synonym: another_invalid_senior, junior_synonym: taxon
      taxon.update_current_valid_taxon
      expect(taxon.current_valid_taxon).to be_nil
    end
    it "should handle when there's a synonym of a synonym" do
      senior_synonym = create_genus
      synonym = create_genus status: 'synonym'
      Synonym.create! junior_synonym: synonym, senior_synonym: senior_synonym
      synonym_of_synonym = create_genus status: 'synonym'
      Synonym.create! junior_synonym: synonym_of_synonym, senior_synonym: synonym
      synonym.update_current_valid_taxon
      expect(synonym.current_valid_taxon).to eq(senior_synonym)
    end
  end

  describe "update_biogeographic_region" do
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
        expect(taxon.biogeographic_region).to be_nil
      end
      it "should do the replacement if there's a replacement defined" do
        protonym = FactoryGirl.create :protonym, locality: 'San Pedro'
        taxon = create_genus protonym: protonym
        taxon.update_biogeographic_region_from_locality make_map 'SAN PEDRO' => 'Africa'
        expect(taxon.biogeographic_region).to eq('Africa')
      end
      it "should not do the replacement if it's a fossil taxon" do
        protonym = FactoryGirl.create :protonym, locality: 'San Pedro'
        taxon = create_genus protonym: protonym, fossil: true
        taxon.update_biogeographic_region_from_locality make_map 'SAN PEDRO' => 'Africa'
        expect(taxon.biogeographic_region).to be_nil
      end
      it "should be case-insensitive" do
        protonym = FactoryGirl.create :protonym, locality: 'San Pedro'
        taxon = create_genus protonym: protonym
        taxon.update_biogeographic_region_from_locality make_map 'SAN PEDRO' => 'Africa'
        expect(taxon.biogeographic_region).to eq('Africa')
      end
      it "should treat 'none' as nil" do
        protonym = FactoryGirl.create :protonym, locality: 'San Pedro'
        taxon = create_genus protonym: protonym
        taxon.update_biogeographic_region_from_locality make_map 'SAN PEDRO' => 'none'
        expect(taxon.biogeographic_region).to be_nil
      end
    end

    describe "Reporting" do
      it "should show which localities in Flávia's document weren't used" do
        allow(File).to receive(:open).and_return "America 3\tNuevo\n"
        expect(Taxon.biogeographic_regions_for_localities).to eq({'AMERICA' => {biogeographic_region: 'Nuevo', used_count: 0}})
      end
      it "should not show taxa which were used" do
        protonym = FactoryGirl.create :protonym, locality: 'America'
        taxon = create_genus protonym: protonym
        allow(File).to receive(:open).and_return "America 3\tNuevo\n"
        map = Taxon.biogeographic_regions_for_localities
        taxon.update_biogeographic_region_from_locality map
        expect(map).to eq({'AMERICA' => {biogeographic_region: 'Nuevo', used_count: 1}})
      end
    end

    describe "Reading Flávia's document to produce locality-to-biogregion mapping" do
      it "should strip the counts and create a hash" do
        allow(File).to receive(:open).and_return "America 3\tNuevo\n"
        expect(Taxon.biogeographic_regions_for_localities).to eq({'AMERICA' => {biogeographic_region: 'Nuevo', used_count: 0}})
      end
    end
  end
end
