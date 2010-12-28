require 'spec_helper'

describe Bolton::ReferenceMatcher do
  it "should find the appropriate Ward reference(s) for each" do
    # exact match
    exact_ward = Factory :reference, :author_names => [Factory :author_name, :name => 'Dlussky, G.M.']
    exact_bolton = Factory :bolton_reference, :authors => 'Dlussky, G.M.'
    unmatching_ward = Factory :reference, :author_names => [Factory :author_name, :name => 'Fisher, B.L.']
    unmatched_bolton = Factory :bolton_reference, :authors => 'Wheeler, W.M.'

    Bolton::Reference.should_receive(:all).and_return [exact_bolton, unmatched_bolton]
    exact_bolton.should_receive(:<=>).and_return 1
    unmatched_bolton.should_not_receive(:<=>)

    Bolton::ReferenceMatcher.new.find_matches_for_all

    Bolton::Match.count.should == 1
    exact_bolton.references.should == [exact_ward]
  end
end
