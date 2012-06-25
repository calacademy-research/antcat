# coding: UTF-8
require 'spec_helper'

describe SpeciesForwardRef do

  describe "The object" do
    before do
      @valid_attributes = {
        fixee:           FactoryGirl.create(:species),
        fixee_attribute: 'synonym_id',
        genus:           FactoryGirl.create(:genus),
        epithet:         'major',
      }
    end
    it "is valid with the valid attributes" do
      SpeciesForwardRef.new(@valid_attributes).should be_valid
    end
    it "needs a fixee" do
      @valid_attributes.delete :fixee
      SpeciesForwardRef.new(@valid_attributes).should_not be_valid
    end
    it "needs a fixee_attribute" do
      @valid_attributes.delete :fixee_attribute
      SpeciesForwardRef.new(@valid_attributes).should_not be_valid
    end
    it "needs a genus" do
      @valid_attributes.delete :genus
      SpeciesForwardRef.new(@valid_attributes).should_not be_valid
    end
    it "needs a epithet" do
      @valid_attributes.delete :epithet
      SpeciesForwardRef.new(@valid_attributes).should_not be_valid
    end
  end
end
