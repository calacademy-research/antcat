require 'spec_helper'

describe DedupeSynonyms do

  it "should delete one of duplicate synonyms" do
    senior = create_genus
    junior = create_genus
    Synonym.create! senior_synonym: senior, junior_synonym: junior
    Synonym.create! senior_synonym: senior, junior_synonym: junior
    another_senior = create_genus
    another_junior = create_genus
    Synonym.create! senior_synonym: another_senior, junior_synonym: another_junior
    expect(Synonym.count).to eq 3
    DedupeSynonyms.dedupe
    expect(Synonym.count).to eq 2
  end

end
