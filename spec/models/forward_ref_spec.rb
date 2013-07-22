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
      ForwardRef.new(@valid_attributes).should be_valid
    end
    it "needs a fixee" do
      @valid_attributes.delete :fixee
      ForwardRef.new(@valid_attributes).should_not be_valid
    end
    it "needs a fixee_attribute" do
      @valid_attributes.delete :fixee_attribute
      ForwardRef.new(@valid_attributes).should_not be_valid
    end
  end

  describe "Fixing up all forward references" do
    it "should call each's fixup method" do
      first = double
      second = double
      ForwardRef.should_receive(:all).and_return [first, second]
      first.should_receive :fixup
      second.should_receive :fixup
      ForwardRef.fixup
    end
  end

end
