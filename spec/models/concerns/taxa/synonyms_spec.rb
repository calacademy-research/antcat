require "spec_helper"

describe Taxa::Synonyms do
  describe "#junior_synonyms_recursive" do
    let(:taxon) { create :family }

    context "when there are no `junior_synonyms`" do
      specify { expect(taxon.junior_synonyms_recursive).to be_empty }
    end

    context "when there are direct junior_synonyms" do
      let(:junior_synonym) { create :family }
      let(:another_junior_synonym) { create :family }

      before do
        create :synonym, senior_synonym: taxon, junior_synonym: junior_synonym
        create :synonym, senior_synonym: taxon, junior_synonym: another_junior_synonym
      end

      specify do
        expect(taxon.junior_synonyms_recursive).to eq [junior_synonym, another_junior_synonym]
      end
    end

    context "when there are nested `junior_synonyms`" do
      let(:junior_synonym) { create :family }
      let(:nested_junior_synonym) { create :family }
      let(:deeply_nested_junior_synonym) { create :family }
      let(:another_deeply_nested_junior_synonym) { create :family }

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
