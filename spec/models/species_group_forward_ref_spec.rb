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

  describe "Fixing up all forward references" do
    it "should call each's fixup method" do
      first = mock
      second = mock
      SpeciesGroupForwardRef.should_receive(:all).and_return [first, second]
      first.should_receive :fixup
      second.should_receive :fixup
      SpeciesGroupForwardRef.fixup
    end
  end

  describe "Fixing up one forward reference" do
    before do
      @genus = create_genus 'Atta'
    end

    describe "Fixing up forward reference to parent species of subspecies" do
      it "should find a senior synonym subspecies" do
        species = create_species 'Atta molestans', genus: @genus
        subspecies = create_subspecies genus: @genus
        forward_ref = SpeciesGroupForwardRef.create!({
          fixee: subspecies, fixee_attribute: 'species',
          genus: @genus, epithet: 'molestans'
        })
        forward_ref.fixup
        subspecies.reload
        subspecies.species.name.to_s.should == 'Atta molestans'
      end
    end

    it "should add a senior synonym matching a name" do
      junior = create_species
      synonym = Synonym.create! junior_synonym: junior
      forward_ref = SpeciesGroupForwardRef.create!({
        fixee: synonym, fixee_attribute: 'senior_synonym',
        genus: @genus, epithet: 'major'
      })
      senior = create_species 'Atta major', genus: @genus
      forward_ref.fixup
      synonym.reload
      junior = synonym.junior_synonym
      senior = synonym.senior_synonym
      junior.senior_synonyms.should == [senior]
      junior.should be_synonym_of  senior
      senior.junior_synonyms.should == [junior]
    end

    it "clear the attribute and record an error if there are no results" do
      junior = create_species
      synonym = Synonym.create! junior_synonym: junior
      forward_ref = SpeciesGroupForwardRef.create!({
        fixee: synonym, fixee_attribute: 'senior_synonym',
        genus: @genus, epithet: 'major'
      })
      Progress.should_receive :error
      forward_ref.fixup
      junior = synonym.reload.junior_synonym
      junior.should have(0).senior_synonyms
      junior.should have(0).junior_synonyms
    end

    it "clear the attribute and record an error if there is more than one result" do
      junior = create_species
      synonym = Synonym.create! junior_synonym: junior
      forward_ref = SpeciesGroupForwardRef.create!({
        fixee: synonym, fixee_attribute: 'senior_synonym',
        genus: @genus, epithet: 'major'
      })
      2.times {create_species 'Atta major', genus: @genus}
      Progress.should_receive :error
      forward_ref.fixup
      junior = synonym.reload.junior_synonym
      junior.should have(0).senior_synonyms
      junior.should have(0).junior_synonyms
    end

    it "should use declension rules to find Atta magnus when the synonym is to Atta magna" do
      junior = create_species genus: @genus
      synonym = Synonym.create! junior_synonym: junior
      forward_ref = SpeciesGroupForwardRef.create!({
        fixee: synonym, fixee_attribute: 'senior_synonym',
        genus: @genus, epithet: 'magna'
      })
      senior = create_species 'Atta magnus', genus: @genus
      forward_ref.fixup
      synonym.reload
      junior = synonym.junior_synonym
      senior = synonym.senior_synonym
      junior.senior_synonyms.should == [senior]
      junior.should be_synonym_of senior
      senior.junior_synonyms.should == [junior]
    end

    it "should find a senior synonym subspecies" do
      junior = create_subspecies genus: @genus
      synonym = Synonym.create! junior_synonym: junior
      forward_ref = SpeciesGroupForwardRef.create!({
        fixee: synonym, fixee_attribute: 'senior_synonym',
        genus: @genus, epithet: 'molestans'
      })
      senior = create_subspecies 'Atta magnus molestans', genus: @genus
      forward_ref.fixup
      junior = synonym.reload.junior_synonym
      junior.should be_synonym_of senior
      junior.senior_synonyms.should == [senior]
    end

    it "should pick the validest target when fixing up" do
      junior = create_species genus: @genus
      synonym = Synonym.create! junior_synonym: junior
      forward_ref = SpeciesGroupForwardRef.create!({
        fixee: synonym, fixee_attribute: 'senior_synonym',
        genus: @genus, epithet: 'magna'
      })
      invalid_senior = create_species 'Atta magnus', genus: @genus, status: 'homonym'
      senior = create_species 'Atta magnus', genus: @genus
      forward_ref.fixup
      junior = synonym.reload.junior_synonym
      junior.should be_synonym_of senior
      junior.senior_synonyms.should == [senior]
    end

  end
end
