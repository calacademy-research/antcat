require "spec_helper"

describe Taxa::Synonyms do
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
