# coding: UTF-8
require 'spec_helper'

describe ForwardRef do

  describe "The object" do
    before do
      @species = create_species
      @synonym = Synonym.create! junior_synonym: @species
      @valid_attributes = {
        fixee:           @synonym,
        fixee_attribute: 'senior_synonym',
      }
    end
    it "is valid with the valid attributes" do
      expect(ForwardRef.new(@valid_attributes)).to be_valid
    end
    it "needs a fixee" do
      @valid_attributes.delete :fixee
      expect(ForwardRef.new(@valid_attributes)).not_to be_valid
    end
    it "needs a fixee_attribute" do
      @valid_attributes.delete :fixee_attribute
      expect(ForwardRef.new(@valid_attributes)).not_to be_valid
    end
  end

  describe "Fixing up all forward references" do
    it "should call each's fixup method" do
      first = double
      second = double
      expect(ForwardRef).to receive(:all).and_return [first, second]
      expect(first).to receive :fixup
      expect(second).to receive :fixup
      ForwardRef.fixup
    end
  end

end
