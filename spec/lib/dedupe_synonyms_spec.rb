# coding: UTF-8
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
    Synonym.count.should == 3
    DedupeSynonyms.dedupe
    Synonym.count.should == 2
  end

end
