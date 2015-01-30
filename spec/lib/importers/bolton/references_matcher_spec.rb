# coding: UTF-8
require 'spec_helper'

describe Importers::Bolton::ReferencesMatcher do

  it "should find the appropriate reference(s) for each" do
    matching_reference = FactoryGirl.create :reference, :author_names => [FactoryGirl.create(:author_name, :name => 'Dlussky, G.M.')]
    matched_bolton = FactoryGirl.create :bolton_reference, :authors => 'Dlussky, G.M.'
    unmatching_reference = FactoryGirl.create :reference, :author_names => [FactoryGirl.create(:author_name, :name => 'Fisher, B.L.')]
    unmatched_bolton = FactoryGirl.create :bolton_reference, :authors => 'Wheeler, W.M.'

    expect(Bolton::Reference).to receive(:all).and_return [matched_bolton, unmatched_bolton]
    expect(matched_bolton).to receive(:<=>).and_return 0.90
    expect(unmatched_bolton).not_to receive(:<=>)

    Importers::Bolton::ReferencesMatcher.new.find_matches_for_all

    expect(Bolton::Match.count).to eq(1)
    expect(Bolton::Match.first.similarity).to eq(0.90)
    expect(matched_bolton.possible_matches).to eq([matching_reference])
    expect(matched_bolton.match).to eq(matching_reference)
    expect(matched_bolton.match_status).to eq('auto')

    expect(unmatched_bolton.match).to be_nil
    expect(unmatched_bolton.match_status).to be_nil
    expect(unmatched_bolton.possible_matches).to be_empty
  end

  #it "should be able to be re-run without changing any manual matches/unmatchables" do
    ## run auto-matching
    #matching_reference = FactoryGirl.create :reference, :author_names => [FactoryGirl.create(:author_name, :name => 'Dlussky, G.M.')]
    #matched_bolton = FactoryGirl.create :bolton_reference, :authors => 'Dlussky, G.M.'
    #Importers::Bolton::ReferencesMatcher.new.find_matches_for_all

    ## check the results of the auto-matching
    #Bolton::Match.count.should == 1
    #Bolton::Match.first.similarity.should == 0.90
    #matched_bolton.possible_matches.should == [matching_reference]
    #matched_bolton.match.should == matching_reference
    #matched_bolton.match_status.should == 'auto'

    ## match it manually
    #unmatching_reference = FactoryGirl.create :reference, :author_names => [FactoryGirl.create(:author_name, :name => 'Fisher, B.L.')]
    #matched_bolton.match_status = 'manual'
    #matched_bolton.match = unmatching_reference
    #matched_bolton.save!

    ## run auto-matching again
    #Importers::Bolton::ReferencesMatcher.new.find_matches_for_all

    ## and make sure the manual stuff stayed
    #matched_bolton.match_status = 'manual'
    #matched_bolton.match = unmatching_reference
  #end

end
