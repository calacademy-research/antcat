require 'spec_helper'

describe Synonym do

  it { should validate_presence_of(:junior_synonym) }

  describe "Finding and creating" do
    before do
      @junior = create_species
      @senior = create_species
    end
    it "should create the synonym if it doesn't exist" do
      Synonym.find_or_create @junior, @senior
      expect(Synonym.count).to eq 1

      synonym = Synonym.where(junior_synonym_id: @junior, senior_synonym_id: @senior)
      expect(synonym.count).to eq 1
    end
    it "should return the existing synonym" do
      Synonym.create! junior_synonym: @junior, senior_synonym: @senior
      expect(Synonym.count).to eq 1

      synonym = Synonym.where(junior_synonym_id: @junior, senior_synonym_id: @senior)
      expect(synonym.count).to eq 1

      Synonym.find_or_create @junior, @senior
      expect(Synonym.count).to eq 1

      synonym = Synonym.where(junior_synonym_id: @junior, senior_synonym_id: @senior)
      expect(synonym.count).to eq 1
    end
  end

  describe "Versioning" do
    it "should record versions" do
      with_versioning do
        synonym = create :synonym
        expect(synonym.versions.last.event).to eq 'create'
      end
    end
  end

end
