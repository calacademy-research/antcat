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

  describe "Fixing up" do

    describe "Fixing up all forward references" do
      it "should call each's fixup method" do
        first = mock
        second = mock
        SpeciesForwardRef.should_receive(:all).and_return [first, second]
        first.should_receive :fixup
        second.should_receive :fixup
        SpeciesForwardRef.fixup
      end
    end

    describe "Fixing up one forward reference" do

      it "should set the synonym_of attribute to a taxon matching a name" do
        genus = create_genus 'Atta'
        fixee = create_species
        forward_ref = SpeciesForwardRef.create!({
          fixee: fixee, fixee_attribute: 'synonym_of_id',
          genus: genus, epithet: 'major'
        })
        fixer = create_species genus: genus,
          name: FactoryGirl.create(:species_name, name: 'Atta major', epithet: 'major')

        forward_ref.fixup

        fixee = Taxon.find fixee
        fixee.synonym_of.should == fixer
      end

      it "clear the attribute and record an error if there are no results" do
        genus = create_genus 'Atta'
        fixee = create_species
        forward_ref = SpeciesForwardRef.create!({
          fixee: fixee, fixee_attribute: 'synonym_of_id',
          genus: genus, epithet: 'major'
        })
        Progress.should_receive :error

        forward_ref.fixup

        fixee = Taxon.find fixee
        fixee.synonym_of.should be_nil
      end

      it "clear the attribute and record an error if there is more than one results" do
        genus = create_genus 'Atta'
        fixee = create_species
        forward_ref = SpeciesForwardRef.create!({
          fixee: fixee, fixee_attribute: 'synonym_of_id',
          genus: genus, epithet: 'major'
        })
        name = FactoryGirl.create :species_name, name: 'Atta major', epithet: 'major'
        2.times {create_species genus: genus, name: name}
        Progress.should_receive :error

        forward_ref.fixup

        fixee = Taxon.find fixee
        fixee.synonym_of.should be_nil
      end

    end
  end
end
