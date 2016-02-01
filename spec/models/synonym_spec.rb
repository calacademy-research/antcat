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

end
