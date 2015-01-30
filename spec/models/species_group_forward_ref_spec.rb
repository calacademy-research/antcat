# coding: UTF-8
require 'spec_helper'

describe SpeciesGroupForwardRef do

  describe "The object" do
    before do
      @species = create_species
      @synonym = Synonym.create! junior_synonym: @species
      @valid_attributes = {
        fixee:           @synonym,
        fixee_attribute: 'senior_synonym',
        genus:           create_genus,
        epithet:         'major',
      }
    end
    it "is valid with the valid attributes" do
      expect(SpeciesGroupForwardRef.new(@valid_attributes)).to be_valid
    end
    it "needs a fixee" do
      @valid_attributes.delete :fixee
      expect(SpeciesGroupForwardRef.new(@valid_attributes)).not_to be_valid
    end
    it "needs a fixee_attribute" do
      @valid_attributes.delete :fixee_attribute
      expect(SpeciesGroupForwardRef.new(@valid_attributes)).not_to be_valid
    end
    it "needs a genus" do
      @valid_attributes.delete :genus
      expect(SpeciesGroupForwardRef.new(@valid_attributes)).not_to be_valid
    end
    it "needs a epithet" do
      @valid_attributes.delete :epithet
      expect(SpeciesGroupForwardRef.new(@valid_attributes)).not_to be_valid
    end
  end

end
