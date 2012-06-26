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

    it "clear the attribute and record an error if there is more than one result" do
      genus = create_genus 'Atta'
      fixee = create_species
      forward_ref = SpeciesForwardRef.create!({
        fixee: fixee, fixee_attribute: 'synonym_of_id',
        genus: genus, epithet: 'major'
      })
      name = create_name 'Atta major'
      2.times {create_species genus: genus, name: name}
      Progress.should_receive :error

      forward_ref.fixup

      fixee = Taxon.find fixee
      fixee.synonym_of.should be_nil
    end

    it "should use declension rules to find Atta magnus when the synonym is to Atta magna" do
      genus = create_genus 'Atta'
      fixee = create_species genus: genus
      forward_ref = SpeciesForwardRef.create!({
        fixee: fixee, fixee_attribute: 'synonym_of_id',
        genus: genus, epithet: 'magna'
      })
      fixer = create_species 'Atta magnus', genus: genus

      forward_ref.fixup

      fixee = Taxon.find fixee
      fixee.synonym_of.should == fixer
    end

    describe "Picking the validest target" do
      it "should pick the validest target when fixing up" do
        genus = create_genus 'Atta'
        fixee = create_species genus: genus
        forward_ref = SpeciesForwardRef.create!({
          fixee: fixee, fixee_attribute: 'synonym_of_id',
          genus: genus, epithet: 'magna'
        })
        invalid_fixer = create_species 'Atta magnus', genus: genus, status: 'homonym'
        fixer = create_species 'Atta magnus', genus: genus

        forward_ref.fixup

        fixee = Taxon.find fixee
        fixee.synonym_of.should == fixer
      end

      it "should return nil if there is none" do
        targets = []
        SpeciesForwardRef.pick_validest(targets).should be_nil
      end

      it "should return nil if there is none" do
        targets = nil
        SpeciesForwardRef.pick_validest(targets).should be_nil
      end

      it "should pick the best target, if there is more than one" do
        invalid_species = create_species status: 'homonym'
        valid_species = create_species status: 'valid'
        targets = [invalid_species, valid_species]
        SpeciesForwardRef.pick_validest(targets).should == valid_species
      end

      it "should raise log an error and return nil if there is more than one valid" do
        valid_species = create_species
        another_valid_species = create_species
        targets = [another_valid_species, valid_species]
        Progress.should_receive :error
        SpeciesForwardRef.pick_validest(targets).should be_nil
      end

      it "should not pick the homonym, no matter what" do
        homonym_species = create_species status: 'homonym'
        targets = [homonym_species]
        SpeciesForwardRef.pick_validest(targets).should be_nil
      end

    end
  end
end
