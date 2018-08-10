require "spec_helper"

describe Taxon do # rubocop:disable RSpec/FilePath
  describe "#junior_synonyms_recursive" do
    let(:taxon) { create_species }

    context "when there are no `junior_synonyms`" do
      specify { expect(taxon.junior_synonyms_recursive).to be_empty }
    end

    context "when there are direct junior_synonyms" do
      let(:junior_synonym) { create_species }
      let(:another_junior_synonym) { create_species }

      before do
        create :synonym, senior_synonym: taxon, junior_synonym: junior_synonym
        create :synonym, senior_synonym: taxon, junior_synonym: another_junior_synonym
      end

      specify do
        expect(taxon.junior_synonyms_recursive).to eq [junior_synonym, another_junior_synonym]
      end
    end

    context "when there are nested `junior_synonyms`" do
      let(:junior_synonym) { create_species }
      let(:nested_junior_synonym) { create_species }
      let(:deeply_nested_junior_synonym) { create_species }
      let(:another_deeply_nested_junior_synonym) { create_species }

      before do
        create :synonym, senior_synonym: taxon, junior_synonym: junior_synonym
        create :synonym, senior_synonym: junior_synonym, junior_synonym: nested_junior_synonym
        create :synonym, senior_synonym: nested_junior_synonym, junior_synonym: deeply_nested_junior_synonym
        create :synonym, senior_synonym: nested_junior_synonym, junior_synonym: another_deeply_nested_junior_synonym
      end

      specify do
        expect(taxon.junior_synonyms_recursive).to eq [
          junior_synonym,
          nested_junior_synonym,
          deeply_nested_junior_synonym,
          another_deeply_nested_junior_synonym
        ]
      end
    end
  end

  it "can be a synonym" do
    taxon = build :family
    expect(taxon).not_to be_synonym
    taxon.update_attribute :status, Status::SYNONYM
    expect(taxon).to be_synonym
    expect(taxon).to be_invalid
  end

  it "can have junior and senior synonyms" do
    senior = create_genus 'Atta'
    junior = create_genus 'Eciton'
    create :synonym, junior_synonym: junior, senior_synonym: senior

    expect(senior.junior_synonyms.count).to eq 1
    expect(senior.senior_synonyms.count).to eq 0
    expect(junior.senior_synonyms.count).to eq 1
    expect(junior.junior_synonyms.count).to eq 0
  end

  describe "Reversing synonymy" do
    it "makes one the synonym of the other and set statuses" do
      atta = create_genus 'Atta'
      attaboi = create_genus 'Attaboi'

      become_junior_synonym_of atta, attaboi
      atta.reload
      attaboi.reload
      expect(atta.senior_synonyms).to include attaboi

      become_junior_synonym_of attaboi, atta
      atta.reload
      attaboi.reload
      expect(attaboi.status).to eq Status::SYNONYM
      expect(attaboi.senior_synonyms).to include atta
      expect(atta.status).to eq Status::VALID
      expect(atta.senior_synonyms).not_to include attaboi
    end

    it "doesn't create duplicate synonym in case of synonym cycle" do
      atta = create_genus 'Atta', status: Status::SYNONYM
      attaboi = create_genus 'Attaboi', status: Status::SYNONYM

      create :synonym, junior_synonym: atta, senior_synonym: attaboi
      create :synonym, junior_synonym: attaboi, senior_synonym: atta
      expect(Synonym.count).to eq 2

      become_junior_synonym_of atta, attaboi
      expect(Synonym.count).to eq 1
      expect(atta.senior_synonyms).to include attaboi
      expect(attaboi.senior_synonyms).not_to include atta
    end
  end

  describe "Removing synonymy" do
    it "removes all synonymies for the taxon" do
      atta = create_genus 'Atta'
      attaboi = create_genus 'Attaboi'
      become_junior_synonym_of attaboi, atta
      expect(atta.junior_synonyms.all.include?(attaboi)).to be true
      expect(atta).not_to be_synonym
      expect(attaboi).to be_synonym
      expect(attaboi.senior_synonyms.all.include?(atta)).to be true

      become_not_junior_synonym_of attaboi, atta

      expect(atta.junior_synonyms.all.include?(attaboi)).to be false
      expect(atta).not_to be_synonym
      expect(attaboi).not_to be_synonym
      expect(attaboi.senior_synonyms.all.include?(atta)).to be false
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

      atta.update_attribute :status, Status::VALID

      expect(atta).not_to be_synonym
      expect(atta.senior_synonyms.size).to eq 0
      expect(eciton.junior_synonyms.size).to eq 0
    end
  end

  describe "with_own_id" do
    let(:atta) { create_genus 'Atta' }
    let(:eciton) { create_genus 'Eciton' }

    before { become_junior_synonym_of eciton, atta }

    describe "#junior_synonyms_with_own_id" do
      it "works" do
        results = atta.junior_synonyms_with_own_id
        expect(results.size).to eq 1
        record = results.first
        expect(record.id).to eq Synonym.find_by(junior_synonym: eciton).id
        expect(record.taxon_id).to eq eciton.id
      end
    end

    describe "#senior_synonyms_with_own_id" do
      it "works" do
        results = eciton.senior_synonyms_with_own_id
        expect(results.size).to eq 1
        record = results.first
        expect(record.id).to eq Synonym.find_by(senior_synonym: atta).id
        expect(record.taxon_id).to eq atta.id
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
    create :synonym, junior_synonym: junior, senior_synonym: senior
    senior.update! status: Status::VALID
    junior.update! status: Status::SYNONYM
  end

  def become_not_junior_synonym_of junior, senior
    Synonym.where(junior_synonym: junior, senior_synonym: senior).destroy_all
    junior.update! status: Status::VALID if junior.senior_synonyms.empty?
  end
end
