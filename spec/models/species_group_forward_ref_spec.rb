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
      SpeciesGroupForwardRef.new(@valid_attributes).should be_valid
    end
    it "needs a fixee" do
      @valid_attributes.delete :fixee
      SpeciesGroupForwardRef.new(@valid_attributes).should_not be_valid
    end
    it "needs a fixee_attribute" do
      @valid_attributes.delete :fixee_attribute
      SpeciesGroupForwardRef.new(@valid_attributes).should_not be_valid
    end
    it "needs a genus" do
      @valid_attributes.delete :genus
      SpeciesGroupForwardRef.new(@valid_attributes).should_not be_valid
    end
    it "needs a epithet" do
      @valid_attributes.delete :epithet
      SpeciesGroupForwardRef.new(@valid_attributes).should_not be_valid
    end
  end

end
