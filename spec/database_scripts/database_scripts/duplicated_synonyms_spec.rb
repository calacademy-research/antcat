require "spec_helper"

describe DatabaseScripts::DuplicatedSynonyms do
  describe "#results" do
    before do
      senior = create_genus
      junior = create_genus
      create :synonym, senior_synonym: senior, junior_synonym: junior
      create :synonym, senior_synonym: senior, junior_synonym: junior
      another_senior = create_genus
      another_junior = create_genus
      create :synonym, senior_synonym: another_senior, junior_synonym: another_junior
    end

    it "returns one of the duplicate synonyms" do
      expect(Synonym.count).to eq 3
      expect(described_class.new.results.count).to eq 1
    end
  end
end
