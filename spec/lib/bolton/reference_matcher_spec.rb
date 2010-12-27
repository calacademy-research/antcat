require 'spec_helper'

describe Bolton::ReferenceMatcher do
  describe "matching all references" do
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

  describe "matching Bolton's references against Ward's" do
    before do
      @matcher = Bolton::ReferenceMatcher.new
      @ward = ArticleReference.create! :author_names => [Factory :author_name, :name => "Ward, P. S."],
                                       :title => "My life among the ants",
                                       :journal => Factory(:journal, :name => "Psyche"),
                                       :series_volume_issue => '1',
                                       :pagination => '15-43',
                                       :citation_year => '1965'
      @bolton = Bolton::Reference.create! :authors => "Ward, P. S.",
                                          :title => "My life among the ants",
                                          :reference_type => 'ArticleReference',
                                          :series_volume_issue => '1',
                                          :pagination => '15-43',
                                          :journal => 'Psyche',
                                          :year => '1965a'
    end

    it "should not match an obvious mismatch" do
      @bolton.should_receive(:<=>).and_return 0
      @matcher.find_matches_for @bolton
      @bolton.matches.should be_empty
      Bolton::Match.count.should be_zero
    end

    it "should match an obvious match" do
      @bolton.should_receive(:<=>).and_return 1
      @matcher.find_matches_for @bolton
      Bolton::Match.count.should == 1
      match = @bolton.matches.first
      match.reference.should == @ward
      match.confidence.should == 1
    end
      
    it "should handle an author last name with an apostrophe in it" do
      @ward.update_attributes :author_names => [Factory(:author_name, :name => "Arnol'di, G.")]
      @bolton.update_attributes :authors => "Arnol'di, G."
      @bolton.should_receive(:<=>).and_return 1
      @matcher.find_matches_for @bolton
      Bolton::Match.count.should == 1
      @bolton.references.should == [@ward]
    end

    it "should only save the highest confidence results as matches" do
      author_names = [Factory :author_name, :name => 'Ward, P. S.']
      Reference.delete_all
      @bolton.should_receive(:<=>).with(Factory :reference, :author_names => author_names).and_return 50
      @bolton.should_receive(:<=>).with(Factory :reference, :author_names => author_names).and_return 50
      @bolton.should_receive(:<=>).with(Factory :reference, :author_names => author_names).and_return 1
      @matcher.find_matches_for @bolton
      Bolton::Match.all.map(&:confidence).should == [50, 50]
    end

  end
end
