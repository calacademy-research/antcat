require 'spec_helper'

describe Taxon do
  it "should be able to be a synonym" do
    taxon = FactoryGirl.build :taxon
    expect(taxon).not_to be_synonym
    taxon.update_attribute :status, 'synonym'
    expect(taxon).to be_synonym
    expect(taxon).to be_invalid
  end

  describe "being a synonym of" do
    it "should not think it's a synonym of something when it's not" do
      genus = FactoryGirl.create :genus
      another_genus = FactoryGirl.create :genus
      expect(genus).not_to be_synonym_of another_genus
    end
    it "should think it's a synonym of something when it is" do
      senior = FactoryGirl.create :genus
      junior = create_synonym senior
      expect(junior).to be_synonym_of senior
    end
  end

  it "should have junior and senior synonyms" do
    senior = create_genus 'Atta'
    junior = create_genus 'Eciton'
    Synonym.create! junior_synonym: junior, senior_synonym: senior
    expect(senior.junior_synonyms.count).to eq(1)
    expect(senior.senior_synonyms.count).to eq(0)
    expect(junior.senior_synonyms.count).to eq(1)
    expect(junior.junior_synonyms.count).to eq(0)
  end

  describe "Reversing synonymy" do
    it "should make one the synonym of the other and set statuses" do
      atta = create_genus 'Atta'
      attaboi = create_genus 'Attaboi'

      atta.become_junior_synonym_of attaboi
      atta.reload; attaboi.reload
      expect(atta).to be_synonym_of attaboi

      attaboi.become_junior_synonym_of atta
      atta.reload; attaboi.reload
      expect(attaboi.status).to eq('synonym')
      expect(attaboi).to be_synonym_of atta
      expect(atta.status).to eq('valid')
      expect(atta).not_to be_synonym_of attaboi
    end

    it "should not create duplicate synonym in case of synonym cycle" do
      atta = create_genus 'Atta', status: 'synonym'
      attaboi = create_genus 'Attaboi', status: 'synonym'
      Synonym.create! junior_synonym: atta, senior_synonym: attaboi
      Synonym.create! junior_synonym: attaboi, senior_synonym: atta
      expect(Synonym.count).to eq(2)

      atta.become_junior_synonym_of attaboi
      expect(Synonym.count).to eq(1)
      expect(atta).to be_synonym_of attaboi
      expect(attaboi).not_to be_synonym_of atta
    end
  end

  describe "Removing synonymy" do
    it "should remove all synonymies for the taxon" do
      atta = create_genus 'Atta'
      attaboi = create_genus 'Attaboi'
      attaboi.become_junior_synonym_of atta
      expect(atta.junior_synonyms.all.include?(attaboi)).to be_truthy
      expect(atta).not_to be_synonym
      expect(attaboi).to be_synonym
      expect(attaboi.senior_synonyms.all.include?(atta)).to be_truthy

      attaboi.become_not_junior_synonym_of atta

      expect(atta.junior_synonyms.all.include?(attaboi)).to be_falsey
      expect(atta).not_to be_synonym
      expect(attaboi).not_to be_synonym
      expect(attaboi.senior_synonyms.all.include?(atta)).to be_falsey
    end
  end

  describe "Deleting synonyms when status changed" do
    it "should delete synonyms when the status changes from 'synonym'" do
      atta = create_genus
      eciton = create_genus
      atta.become_junior_synonym_of eciton
      expect(atta).to be_synonym
      expect(atta.senior_synonyms.size).to eq(1)
      expect(eciton.junior_synonyms.size).to eq(1)

      atta.update_attribute :status, 'valid'

      expect(atta).not_to be_synonym
      expect(atta.senior_synonyms.size).to eq(0)
      expect(eciton.junior_synonyms.size).to eq(0)
    end
  end

  describe "Junior synonyms with names" do
    it "should work" do
      atta = create_genus 'Atta'
      eciton = create_genus 'Eciton'
      eciton.become_junior_synonym_of atta
      results = atta.junior_synonyms_with_names
      expect(results.size).to eq(1)
      record = results.first
      expect(record['id']).to eq(Synonym.find_by_junior_synonym_id(eciton.id).id)
      expect(record['name']).to eq(eciton.name.to_html)
    end
  end

  describe "Senior synonyms with names" do
    it "should work" do
      atta = create_genus 'Atta'
      eciton = create_genus 'Eciton'
      eciton.become_junior_synonym_of atta
      results = eciton.senior_synonyms_with_names
      expect(results.size).to eq(1)
      record = results.first
      expect(record['id']).to eq(Synonym.find_by_senior_synonym_id(atta.id).id)
      expect(record['name']).to eq(atta.name.to_html)
    end
  end
end
