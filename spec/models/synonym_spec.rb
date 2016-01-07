require 'spec_helper'

describe Synonym do

  describe "The object" do
    it "should require the junior, but not the senior" do
      synonym = Synonym.new
      expect(synonym).not_to be_valid
      synonym.junior_synonym = create_species 'Formica'
      expect(synonym).to be_valid
      synonym.senior_synonym = create_species 'Atta'
      synonym.save!
      synonym.reload
      expect(synonym.junior_synonym.name.to_s).to eq('Formica')
      expect(synonym.senior_synonym.name.to_s).to eq('Atta')
    end
  end

  describe "Finding and creating" do
    before do
      @junior = create_species
      @senior = create_species
    end
    it "should create the synonym if it doesn't exist" do
      Synonym.find_or_create @junior, @senior
      expect(Synonym.count).to eq(1)
      expect(Synonym.where(junior_synonym_id: @junior, senior_synonym_id: @senior).count).to eq(1)
    end
    it "should return the existing synonym" do
      Synonym.create! junior_synonym: @junior, senior_synonym: @senior
      expect(Synonym.count).to eq(1)
      expect(Synonym.where(junior_synonym_id: @junior, senior_synonym_id: @senior).count).to eq(1)

      Synonym.find_or_create @junior, @senior
      expect(Synonym.count).to eq(1)
      expect(Synonym.where(junior_synonym_id: @junior, senior_synonym_id: @senior).count).to eq(1)
    end
  end

  describe "Versioning" do
    it "should record versions" do
      with_versioning do
        synonym = FactoryGirl.create :synonym
        expect(synonym.versions.last.event).to eq('create')
      end
    end
  end

  describe "Finding senior synonyms that aren't valid taxa" do
    it "should return nothing if there are none such" do
      results = Synonym.invalid_senior_synonyms
      expect(results).to eq([])
    end
    it "should return the one invalid synonym" do
      junior = create_species
      invalid_senior = create_species status: 'synonym'
      invalid_synonymy = Synonym.find_or_create junior, invalid_senior
      valid_senior = create_species
      valid_synonymy = Synonym.find_or_create junior, valid_senior

      results = Synonym.invalid_senior_synonyms
      expect(results).to eq([invalid_synonymy])
    end

    it "should return nothing if none invalid" do
      junior = create_species
      valid_senior = create_species
      invalid_synonymy = Synonym.find_or_create junior, valid_senior
      another_valid_senior = create_species
      valid_synonymy = Synonym.find_or_create junior, another_valid_senior

      results = Synonym.invalid_senior_synonyms
      expect(results).to eq([])
    end
    it "should return all if all invalid" do
      junior = create_species
      invalid_senior = create_species status: 'synonym'
      invalid_synonymy = Synonym.find_or_create junior, invalid_senior
      another_invalid_senior = create_species status: 'synonym'
      another_invalid_synonymy = Synonym.find_or_create junior, another_invalid_senior

      results = Synonym.invalid_senior_synonyms
      expect(results).to match_array([invalid_synonymy, another_invalid_synonymy])
    end
  end

end
