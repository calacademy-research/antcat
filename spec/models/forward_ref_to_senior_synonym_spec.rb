# coding: UTF-8
require 'spec_helper'

describe ForwardRefToSeniorSynonym do
  before do
    @genus = create_genus 'Atta'
  end

  it "should add a senior synonym matching a name" do
    junior = create_species 'Atta major'
    synonym = Synonym.create! junior_synonym: junior
    forward_ref = ForwardRefToSeniorSynonym.create!({
      fixee: synonym, fixee_attribute: 'senior_synonym',
      genus: @genus, epithet: 'major'
    })
    senior = create_species name: junior.name, genus: @genus
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
    forward_ref = ForwardRefToSeniorSynonym.create!({
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
    forward_ref = ForwardRefToSeniorSynonym.create!({
      fixee: synonym, fixee_attribute: 'senior_synonym',
      genus: @genus, epithet: 'major'
    })
    2.times {create_species name: junior.name, genus: @genus}
    Progress.should_receive :error
    forward_ref.fixup
    junior = synonym.reload.junior_synonym
    junior.should have(0).senior_synonyms
    junior.should have(0).junior_synonyms
  end

  it "should use declension rules to find Atta magnus when the synonym is to Atta magna" do
    junior = create_species genus: @genus
    synonym = Synonym.create! junior_synonym: junior
    forward_ref = ForwardRefToSeniorSynonym.create!({
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
    forward_ref = ForwardRefToSeniorSynonym.create!({
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
    forward_ref = ForwardRefToSeniorSynonym.create!({
      fixee: synonym, fixee_attribute: 'senior_synonym',
      genus: @genus, epithet: 'magna'
    })
    invalid_senior = create_species 'Atta magnus', genus: @genus, status: 'homonym'
    senior = create_species name: invalid_senior.name, genus: @genus
    forward_ref.fixup
    junior = synonym.reload.junior_synonym
    junior.should be_synonym_of senior
    junior.senior_synonyms.should == [senior]
  end

end
