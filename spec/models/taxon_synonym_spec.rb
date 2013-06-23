# coding: UTF-8
require 'spec_helper'

describe Taxon do
  it "should be able to be a synonym" do
    taxon = FactoryGirl.build :taxon
    taxon.should_not be_synonym
    taxon.update_attribute :status, 'synonym'
    taxon.should be_synonym
    taxon.should be_invalid
  end

  describe "being a synonym of" do
    it "should not think it's a synonym of something when it's not" do
      genus = FactoryGirl.create :genus
      another_genus = FactoryGirl.create :genus
      genus.should_not be_synonym_of another_genus
    end
    it "should think it's a synonym of something when it is" do
      senior = FactoryGirl.create :genus
      junior = create_synonym senior
      junior.should be_synonym_of senior
    end
  end

  it "should have junior and senior synonyms" do
    senior = create_genus 'Atta'
    junior = create_genus 'Eciton'
    Synonym.create! junior_synonym: junior, senior_synonym: senior
    senior.should have(1).junior_synonym
    senior.should have(0).senior_synonyms
    junior.should have(1).senior_synonym
    junior.should have(0).junior_synonyms
  end

  describe "Reversing synonymy" do
    it "should make one the synonym of the other and set statuses" do
      atta = create_genus 'Atta'
      attaboi = create_genus 'Attaboi'

      atta.become_junior_synonym_of attaboi
      atta.reload; attaboi.reload
      atta.should be_synonym_of attaboi

      attaboi.become_junior_synonym_of atta
      atta.reload; attaboi.reload
      attaboi.status.should == 'synonym'
      attaboi.should be_synonym_of atta
      atta.status.should == 'valid'
      atta.should_not be_synonym_of attaboi
    end

    it "should not create duplicate synonym in case of synonym cycle" do
      atta = create_genus 'Atta', status: 'synonym'
      attaboi = create_genus 'Attaboi', status: 'synonym'
      Synonym.create! junior_synonym: atta, senior_synonym: attaboi
      Synonym.create! junior_synonym: attaboi, senior_synonym: atta
      Synonym.count.should == 2

      atta.become_junior_synonym_of attaboi
      Synonym.count.should == 1
      atta.should be_synonym_of attaboi
      attaboi.should_not be_synonym_of atta
    end
  end

  describe "Removing synonymy" do
    it "should remove all synonymies for the taxon" do
      atta = create_genus 'Atta'
      attaboi = create_genus 'Attaboi'
      attaboi.become_junior_synonym_of atta
      atta.junior_synonyms.all.include?(attaboi).should be_true
      atta.should_not be_synonym
      attaboi.should be_synonym
      attaboi.senior_synonyms.all.include?(atta).should be_true

      attaboi.become_not_junior_synonym_of atta

      atta.junior_synonyms.all.include?(attaboi).should be_false
      atta.should_not be_synonym
      attaboi.should_not be_synonym
      attaboi.senior_synonyms.all.include?(atta).should be_false
    end
  end

  describe "Deleting synonyms when status changed" do
    it "should delete synonyms when the status changes from 'synonym'" do
      atta = create_genus
      eciton = create_genus
      atta.become_junior_synonym_of eciton
      atta.should be_synonym
      atta.should have(1).senior_synonym
      eciton.should have(1).junior_synonym

      atta.update_attribute :status, 'valid'

      atta.should_not be_synonym
      atta.should have(0).senior_synonyms
      eciton.should have(0).junior_synonyms
    end
  end

  describe "Junior synonyms with names" do
    it "should work" do
      atta = create_genus 'Atta'
      eciton = create_genus 'Eciton'
      eciton.become_junior_synonym_of atta
      results = atta.junior_synonyms_with_names
      results.should have(1).item
      record = results.first
      record['id'].should == Synonym.find_by_junior_synonym_id(eciton.id).id
      record['name'].should == eciton.name.to_html
    end
  end

  describe "Senior synonyms with names" do
    it "should work" do
      atta = create_genus 'Atta'
      eciton = create_genus 'Eciton'
      eciton.become_junior_synonym_of atta
      results = eciton.senior_synonyms_with_names
      results.should have(1).item
      record = results.first
      record['id'].should == Synonym.find_by_senior_synonym_id(atta.id).id
      record['name'].should == atta.name.to_html
    end
  end
end
