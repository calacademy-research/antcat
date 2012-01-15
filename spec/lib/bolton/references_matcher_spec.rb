# coding: UTF-8
require 'spec_helper'

describe Bolton::ReferencesMatcher do

  it "should find the appropriate reference(s) for each" do
    matching_reference = Factory :reference, author_names: [Factory(:author_name, name: 'Dlussky, G.M.')]
    matched_bolton = Factory :bolton_reference, authors: 'Dlussky, G.M.'
    unmatching_reference = Factory :reference, author_names: [Factory(:author_name, name: 'Fisher, B.L.')]
    unmatched_bolton = Factory :bolton_reference, authors: 'Wheeler, W.M.'

    Bolton::Reference.should_receive(:all).and_return [matched_bolton, unmatched_bolton]
    matched_bolton.should_receive(:<=>).and_return 0.90
    unmatched_bolton.should_not_receive(:<=>)

    Bolton::ReferencesMatcher.new.find_matches_for_all

    Bolton::Match.count.should == 1
    Bolton::Match.first.similarity.should == 0.90
    matched_bolton.possible_matches.should == [matching_reference]
    matched_bolton.match.should == matching_reference
    matched_bolton.match_status.should == 'auto'

    unmatched_bolton.match.should be_nil
    unmatched_bolton.match_status.should be_nil
    unmatched_bolton.possible_matches.should be_empty
  end

end
