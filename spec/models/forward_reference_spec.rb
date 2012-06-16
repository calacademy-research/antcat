# coding: UTF-8
require 'spec_helper'

describe ForwardReference do

  describe "The object" do
    before do
      @valid_attributes = {
        fixee: FactoryGirl.create(:species),
        fixee_attribute: 'synonym_id',
        name: FactoryGirl.create(:species_name),
      }
    end
    it "is valid with a name, fixee and attribute" do
      ForwardReference.new(@valid_attributes).should be_valid
    end
    it "needs a name" do
      @valid_attributes.delete :name
      ForwardReference.new(@valid_attributes).should_not be_valid
    end
    it "has a fixee" do
      @valid_attributes.delete :fixee
      ForwardReference.new(@valid_attributes).should_not be_valid
    end
    it "has a fixee attribute" do
      @valid_attributes.delete :fixee_attribute
      ForwardReference.new(@valid_attributes).should_not be_valid
    end
  end

  describe "Fixing up" do
    describe "Fixing up all forward references" do
      it "should call each's fixup method" do
        first = mock
        second = mock
        ForwardReference.should_receive(:all).and_return [first, second]
        first.should_receive(:fixup)
        second.should_receive(:fixup)

        ForwardReference.fixup
      end
    end

    describe "Fixing up one reference" do

      it "set the synonym_of attribute to a taxon matching a name" do
        genus = FactoryGirl.create :genus
        species_name = FactoryGirl.create :species_name, name: 'Atta minor'
        junior_synonym = FactoryGirl.create :species, genus: genus
        senior_synonym = FactoryGirl.create :species, name: species_name, genus: genus
        forward_reference = ForwardReference.create! fixee: junior_synonym, fixee_attribute: 'synonym_of', name: species_name
        forward_reference.fixup
        taxon = Taxon.find junior_synonym
        taxon.should be_synonym
        taxon.should be_synonym_of senior_synonym
      end

    end
  end

end
