require 'spec_helper'

describe Bolton::ReferenceMatcher do
  describe "matching all references" do
    it "should set the appropriate Ward reference for each" do
      # exact match
      exact_ward = Factory :reference, :author_names => [Factory :author_name, :name => 'Dlussky, G.M.']
      exact_bolton = Factory :bolton_reference, :authors => 'Dlussky, G.M.'
      unmatching_ward = Factory :reference, :author_names => [Factory :author_name, :name => 'Fisher, B.L.']
      unmatched_bolton = Factory :bolton_reference, :authors => 'Wheeler, W.M.'

      Bolton::Reference.should_receive(:all).and_return [exact_bolton, unmatched_bolton]
      exact_bolton.should_receive(:match).and_return 1
      unmatched_bolton.should_not_receive(:match)

      Bolton::ReferenceMatcher.new.find_matches_for_all

      Bolton::Match.count.should == 1
      exact_bolton.references.should == [exact_ward]
    end
  end

  describe "matching Bolton's references against Ward's" do
    before do
      @matcher = Bolton::ReferenceMatcher.new
      @ward = ArticleReference.create! :author_names => [Factory :author_name, :name => "Arnol'di, G."],
                                       :title => "My life among the ants",
                                       :journal => Factory(:journal, :name => "Psyche"),
                                       :series_volume_issue => '1',
                                       :pagination => '15-43',
                                       :citation_year => '1965'
      @bolton = Bolton::Reference.create! :authors => "Arnol'di, G.",
                                          :title => "My life among the ants",
                                          :reference_type => 'ArticleReference',
                                          :series_volume_issue => '1',
                                          :pagination => '15-43',
                                          :journal => 'Psyche',
                                          :year => '1965a'
    end

    it "should not match an obvious mismatch" do
      @bolton.should_receive(:match).and_return 0
      @matcher.find_matches_for @bolton
      @bolton.matches.should be_empty
      Bolton::Match.count.should be_zero
    end

    it "should match an obvious match" do
      @bolton.should_receive(:match).and_return 1
      @matcher.find_matches_for @bolton
      Bolton::Match.count.should == 1
      match = @bolton.matches.first
      match.reference.should == @ward
      match.confidence.should == 1
    end
      
    it "should handle an author last name with an apostrophe in it" do
      @ward.update_attributes :author_names => [Factory(:author_name, :name => "Arnol'di, G.")]
      @bolton.update_attributes :authors => "Arnol'di, G."
      @bolton.should_receive(:match).and_return 1
      @matcher.find_matches_for @bolton
      Bolton::Match.count.should == 1
      @bolton.references.should == [@ward]
    end

    it "should only save the highest confidence results as matches" do
      author_names = [Factory :author_name, :name => 'Ward, P. S.']
      Reference.delete_all
      @bolton.should_receive(:match).with(Factory :reference, :author_names => author_names).and_return 50
      @bolton.should_receive(:match).with(Factory :reference, :author_names => author_names).and_return 50
      @bolton.should_receive(:match).with(Factory :reference, :author_names => author_names).and_return 1
      @matcher.find_matches_for @bolton
      Bolton::Match.all.map(&:confidence).should == [50, 50]
    end

    private

    #it "should find an exact match" do
      #ward = ArticleReference.create! :author_names => [Factory :author_name, :name => 'Fisher, B.L.'],
                                      #:title => "My life among the ants",
                                      #:journal => Factory(:journal, :name => "Psyche"),
                                      #:series_volume_issue => '1',
                                      #:pagination => '15-43',
                                      #:citation_year => '1965'
      #bolton = Bolton::Reference.new :authors => 'Fisher, B.L.',
                                     #:title => "My life among the ants",
                                     #:reference_type => 'ArticleReference',
                                     #:series_volume_issue => '1',
                                     #:pagination => '15-43',
                                     #:journal => 'Psyche',
                                     #:year => '1965a'
      #Bolton::ReferenceMatcher.new.find_match(bolton).should == ward
    #end

    #it "should find a match when Ward has markup" do
      #reference = Reference.create!(:authors => 'Dlussky, G.M.',
                                    #:title => "Ants of the genus *Formica* L. of Mongolia and northeast Tibet",
                                    #:citation => "Annales Zoologici 23: 15-43", :year => '1965a')
      #bolton = Bolton::Reference.new(:authors => 'Dlussky, G.M.', :title_and_citation =>
                                   #"Ants of the genus Formica L. of Mongolia and northeast Tibet. Annales Zoologici 23: 15-43", :year => '1965a')

      #Bolton::ReferenceMatcher.new.find_match(bolton).should == reference
    #end

    #it "should find a match when Ward has extra text" do
      #reference = Reference.create!(:authors => 'Dlussky, G.M.',
                                    #:title => "Ants of the genus *Formica* L. of Mongolia and northeast Tibet (Hymenoptera, Formicidae)",
                                    #:citation => "Annales Zoologici 23: 15-43", :year => '1965a')
      #bolton = Bolton::Reference.new(:authors => 'Dlussky, G.M.', :title_and_citation =>
                                   #"Ants of the genus Formica L. of Mongolia and northeast Tibet. Annales Zoologici 23: 15-43", :year => '1965a')

      #Bolton::ReferenceMatcher.new.find_match(bolton).should == reference
    #end

    #it "should find a match when two entries have similar authors" do
      #Reference.create!(:authors => 'abc', :title => "title", :citation => "citation", :year => 'year')
      #reference = Reference.create!(:authors => 'abd', :title => "another title", :citation => "another citation", :year => 'year')
      #bolton = Bolton::Reference.new(:authors => 'abd', :title_and_citation => "another title another citation", :year => 'year')

      #Bolton::ReferenceMatcher.new.find_match(bolton).should == reference
    #end

    #it "should find a match when there is a long enough common suffix (e.g., from journal title, volume and page)" do
      #ward = Reference.create! :authors => "Arakelian, G. R.; Dlussky, G. M.", :year => '1991',
                               #:title => "Dacetine ants (Hymenoptera: Formicidae) of the USSR. [In Russian.].",
                               #:citation => "Zoologicheskii Zhurnal 70(2):149-152."
      #bolton = Bolton::Reference.new :authors => 'Arakelian, G.R. & Dlussky, G.M.', :year => '1991',
                                   #:title_and_citation => "Murav'i triby Dacetini SSSR. Zoologicheskii Zhurnal 70 (2): 149-152."
      #Bolton::ReferenceMatcher.new.find_match(bolton).should == ward
    #end

    #it "should find a match when Ward includes taxon names" do
      #ward = Reference.create! :authors => "Dlussky, G. M.; Soyunov, O. S.", :year => "1988",
        #:title => "Ants of the genus *Temnothorax* Mayr (Hymenoptera: Formicidae) of the USSR. [In Russian.]",
        #:citation => "Izvestiya Akademii Nauk Turkmenskoi SSR. Seriya Biologicheskikh Nauk 1988(4):29-37"
      #bolton = Bolton::Reference.new :authors => "Dlussky, G.M. & Soyunov, O.S.", :year => "1988",
        #:title_and_citation => "Murav'i roda Temnothorax Mayr SSSR. Izvestiya Akademii Nauk Turkmenskoi SSR. Seriya Biologicheskikh Nauk 1988 (No. 4): 29-37."
      #Bolton::ReferenceMatcher.new.find_match(bolton).should == ward
    #end

    #it "should find a match when Ward includes taxon names, as long as one of them is one we know about" do
      #ward = Reference.create! :authors => "Dlusski, G. M.; Soyunov, O. S.", :year => "1987",
        #:title => "Ants of the genus *Temnothorax* Mayr (Hymenoptera, Chrysidoidea, Vespoidea and Apoidea) of the USSR. [In Russian.]",
        #:citation => "Izvestiya Akademii Nauk Turkmenskoi SSR. Seriya Biologicheskikh N."
      #bolton = Bolton::Reference.new :authors => "Dlussky, G.M. & Soyunov, O.S.", :year => "1988",
        #:title_and_citation => "Murav'i roda Temnothorax Mayr SSSR. Izvestiya Akademii Nauk Turkmenskoi SSR. Seriya Biologicheskikh Nauk"
      #Bolton::ReferenceMatcher.new.find_match(bolton).should == ward
    #end

    #it "should find a match when the author and year are the same, and a sufficient number of digits in the title + citation are the same" do
      #ward = Reference.create! :authors => 'De Geer, C.', :year => '1778', :title => "Mémoires pour servir à l'histoire des insectes. Tome septième (7)",
        #:citation => "Stockholm: Pierre Hesselberg, 950 pp"
      #bolton = Bolton::Reference.new :authors => 'De Geer, C.', :year => '1778', :title_and_citation => "Memoirs pour Servir à l'Histoire des Insectes 7: 950 pp. Stockholm."
      #Bolton::ReferenceMatcher.new.find_match(bolton).should == ward
    #end

    #it "should mark matches as 'suspect' if the authors and year don't match exactly" do
      #ward = Reference.create! :authors => 'De Geer, C.', :year => '1777', :title => "Ants", :citation => "Stockholm: Pierre Hesselberg, 950 pp"
      #bolton = Bolton::Reference.new :authors => 'De Geer, C.', :year => '1778', :title_and_citation => "Ants. Stockholm: Pierre Hesselberg, 950 pp"
      #matcher = Bolton::ReferenceMatcher.new
      #matcher.find_match(bolton).should == ward
      #matcher.should be_suspect
    #end

    #it "should find the best match, not just the first match above the threshold" do
      #Reference.create! :authors => 'De Geer, C.', :year => '1777', :title => "Ants 2", :citation => "Stockholm: Pierre Hesselberg, 950 pp"
      #ward = Reference.create! :authors => 'De Geer, C.', :year => '1777', :title => "Ants 1", :citation => "Stockholm: Pierre Hesselberg, 950 pp"
      #bolton = Bolton::Reference.new :authors => 'De Geer, C.', :year => '1777', :title_and_citation => "Ants 1. Stockholm: Pierre Hesselberg, 950 pp"
      #Bolton::ReferenceMatcher.new.find_match(bolton).should == ward
    #end

  end
end
