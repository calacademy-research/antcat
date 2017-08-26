require 'spec_helper'

describe Taxon do
  it "can be a synonym" do
    taxon = build :taxon
    expect(taxon).not_to be_synonym
    taxon.update_attribute :status, 'synonym'
    expect(taxon).to be_synonym
    expect(taxon).to be_invalid
  end

  describe "#synonym_of?" do
    it "should not think it's a synonym of something when it's not" do
      genus = create :genus
      another_genus = create :genus
      expect(genus).not_to be_synonym_of another_genus
    end

    it "should think it's a synonym of something when it is" do
      senior = create :genus
      junior = create_synonym senior
      expect(junior).to be_synonym_of senior
    end
  end

  it "should have junior and senior synonyms" do
    senior = create_genus 'Atta'
    junior = create_genus 'Eciton'
    Synonym.create! junior_synonym: junior, senior_synonym: senior

    expect(senior.junior_synonyms.count).to eq 1
    expect(senior.senior_synonyms.count).to eq 0
    expect(junior.senior_synonyms.count).to eq 1
    expect(junior.junior_synonyms.count).to eq 0
  end

  describe "Reversing synonymy" do
    it "should make one the synonym of the other and set statuses" do
      atta = create_genus 'Atta'
      attaboi = create_genus 'Attaboi'

      become_junior_synonym_of atta, attaboi
      atta.reload; attaboi.reload
      expect(atta).to be_synonym_of attaboi

      become_junior_synonym_of attaboi, atta
      atta.reload; attaboi.reload
      expect(attaboi.status).to eq 'synonym'
      expect(attaboi).to be_synonym_of atta
      expect(atta.status).to eq 'valid'
      expect(atta).not_to be_synonym_of attaboi
    end

    it "doesn't create duplicate synonym in case of synonym cycle" do
      atta = create_genus 'Atta', status: 'synonym'
      attaboi = create_genus 'Attaboi', status: 'synonym'

      Synonym.create! junior_synonym: atta, senior_synonym: attaboi
      Synonym.create! junior_synonym: attaboi, senior_synonym: atta
      expect(Synonym.count).to eq 2

      become_junior_synonym_of atta, attaboi
      expect(Synonym.count).to eq 1
      expect(atta).to be_synonym_of attaboi
      expect(attaboi).not_to be_synonym_of atta
    end
  end

  describe "Removing synonymy" do
    it "removes all synonymies for the taxon" do
      atta = create_genus 'Atta'
      attaboi = create_genus 'Attaboi'
      become_junior_synonym_of attaboi, atta
      expect(atta.junior_synonyms.all.include?(attaboi)).to be_truthy
      expect(atta).not_to be_synonym
      expect(attaboi).to be_synonym
      expect(attaboi.senior_synonyms.all.include?(atta)).to be_truthy

      become_not_junior_synonym_of attaboi, atta

      expect(atta.junior_synonyms.all.include?(attaboi)).to be_falsey
      expect(atta).not_to be_synonym
      expect(attaboi).not_to be_synonym
      expect(attaboi.senior_synonyms.all.include?(atta)).to be_falsey
    end
  end

  describe "Deleting synonyms when status changed" do
    it "deletes synonyms when the status changes from 'synonym'" do
      atta = create_genus
      eciton = create_genus
      become_junior_synonym_of atta, eciton
      expect(atta).to be_synonym
      expect(atta.senior_synonyms.size).to eq 1
      expect(eciton.junior_synonyms.size).to eq 1

      atta.update_attribute :status, 'valid'

      expect(atta).not_to be_synonym
      expect(atta.senior_synonyms.size).to eq 0
      expect(eciton.junior_synonyms.size).to eq 0
    end
  end

  describe "with_names" do
    let(:atta) { create_genus 'Atta' }
    let(:eciton) { create_genus 'Eciton' }

    before { become_junior_synonym_of eciton, atta }

    describe "#junior_synonyms_with_names" do
      it "works" do
        results = atta.junior_synonyms_with_names
        expect(results.size).to eq 1
        record = results.first
        expect(record['id']).to eq Synonym.find_by(junior_synonym_id: eciton.id).id
        expect(record['name']).to eq eciton.name.to_html
      end
    end

    describe "#senior_synonyms_with_names" do
      it "works" do
        results = eciton.senior_synonyms_with_names
        expect(results.size).to eq 1
        record = results.first
        expect(record['id']).to eq Synonym.find_by(senior_synonym_id: atta.id).id
        expect(record['name']).to eq atta.name.to_html
      end
    end
  end
end

# Used to live in `Taxon` as instance methods, then in a monkey patch. See git.
# Tests calling these may be deprecated, since they're mostly expecting
# on what these methods does. Kept here because I haven't figured out if they are
# WIP and are supposed to be implemented in the future.
def become_junior_synonym_of junior, senior
  Synonym.where(junior_synonym: senior, senior_synonym: junior).destroy_all
  Synonym.where(senior_synonym: senior, junior_synonym: junior).destroy_all
  Synonym.create! junior_synonym: junior, senior_synonym: senior
  senior.update! status: 'valid'
  junior.update! status: 'synonym'
end

def become_not_junior_synonym_of junior, senior
  Synonym.where(junior_synonym: junior, senior_synonym: senior).destroy_all
  junior.update! status: 'valid' if junior.senior_synonyms.empty?
end
