require "spec_helper"

describe Taxa::Synonyms do
  describe "deleting synonyms when status changed" do
    let(:senior) { create :family }
    let(:junior) { create :family, :synonym }

    before do
      create :synonym, junior_synonym: junior, senior_synonym: senior
    end

    it "deletes synonyms when the status changes from 'synonym'" do
      expect(junior).to be_synonym
      expect(junior.senior_synonyms.size).to eq 1
      expect(senior.junior_synonyms.size).to eq 1

      junior.update status: Status::VALID, current_valid_taxon: nil

      expect(junior).not_to be_synonym
      expect(junior.senior_synonyms.size).to eq 0
      expect(senior.junior_synonyms.size).to eq 0
    end
  end

  describe "with_own_id" do
    let(:senior) { create :family }
    let(:junior) { create :family, :synonym }

    before do
      create :synonym, junior_synonym: junior, senior_synonym: senior
    end

    describe "#junior_synonyms_with_own_id" do
      specify do
        results = senior.junior_synonyms_with_own_id
        expect(results.size).to eq 1
        record = results.first
        expect(record.id).to eq Synonym.find_by(junior_synonym: junior).id
        expect(record.taxon_id).to eq junior.id
      end
    end

    describe "#senior_synonyms_with_own_id" do
      specify do
        results = junior.senior_synonyms_with_own_id
        expect(results.size).to eq 1
        record = results.first
        expect(record.id).to eq Synonym.find_by(senior_synonym: senior).id
        expect(record.taxon_id).to eq senior.id
      end
    end
  end
end
