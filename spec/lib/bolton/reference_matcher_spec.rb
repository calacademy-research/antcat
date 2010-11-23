require 'spec_helper'

=begin
describe Bolton::ReferenceMatcher do
  describe "matching all references" do
    it "should set the appropriate Ward reference for each" do
      # exact match
      exact_ward = Reference.create! :authors => 'Dlussky, G.M.',
                        :title => "Ants of the genus Formica L. of Mongolia and northeast Tibet",
                        :citation => "Annales Zoologici 23: 15-43", :year => '1965a'
      exact_bolton = BoltonReference.create! :authors => 'Dlussky, G.M.', :title_and_citation =>
                     "Ants of the genus Formica L. of Mongolia and northeast Tibet. Annales Zoologici 23: 15-43", :year => '1965a'
      # non-match
      Reference.create! :authors => 'Fisher, B.L.', :title => "My life among the ants", :citation => "Playboy", :year => '2009'
      unmatched_bolton = BoltonReference.create! :authors => 'Wheeler, W.M.', :title_and_citation => "Ants, ants, ants!", :year => '1965a'

      # suspect match
      suspect_ward = Reference.create! :authors => 'De Geer, C.', :year => '1777', :title => "Ants",
        :citation => "Stockholm: Pierre Hesselberg, 950 pp"
      suspect_bolton = BoltonReference.create! :authors => 'De Geer, C.', :year => '1778',
        :title_and_citation => "Ants. Stockholm: Pierre Hesselberg, 950 pp"

      Bolton::ReferenceMatcher.new.match_all

      exact_bolton.reload
      exact_bolton.reference.should == exact_ward
      exact_bolton.should_not be_suspect

      unmatched_bolton.reload
      unmatched_bolton.reference.should be_nil
      exact_bolton.should_not be_suspect

      suspect_bolton.reload
      suspect_bolton.reference.should == suspect_ward
      suspect_bolton.should be_suspect
    end
  end
  describe "matching Bolton's references against Ward's" do
    it "should not match an obvious mismatch" do
      Reference.create!(:authors => 'Fisher, B.L.', :title => "My life among the ants", :citation => "Playboy", :year => '2009')
      bolton = BoltonReference.new(:authors => 'Dlussky, G.M.', :title_and_citation =>
                                   "Ants of the genus Formica L. of Mongolia and northeast Tibet. Annales Zoologici 23: 15-43", :year => '1965a')

      Bolton::ReferenceMatcher.new.match(bolton).should be_nil
    end

    it "should find an exact match" do
      ward = Reference.create!(:authors => 'Dlussky, G.M.',
                               :title => "Ants of the genus Formica L. of Mongolia and northeast Tibet",
                               :citation => "Annales Zoologici 23: 15-43", :year => '1965a')
      bolton = BoltonReference.new(:authors => 'Dlussky, G.M.', :title_and_citation =>
                                    "Ants of the genus Formica L. of Mongolia and northeast Tibet. Annales Zoologici 23: 15-43", :year => '1965a')
      Bolton::ReferenceMatcher.new.match(bolton).should == ward
    end

    it "should find a match when Ward has markup" do
      reference = Reference.create!(:authors => 'Dlussky, G.M.',
                                    :title => "Ants of the genus *Formica* L. of Mongolia and northeast Tibet",
                                    :citation => "Annales Zoologici 23: 15-43", :year => '1965a')
      bolton = BoltonReference.new(:authors => 'Dlussky, G.M.', :title_and_citation =>
                                   "Ants of the genus Formica L. of Mongolia and northeast Tibet. Annales Zoologici 23: 15-43", :year => '1965a')

      Bolton::ReferenceMatcher.new.match(bolton).should == reference
    end

    it "should find a match when Ward has extra text" do
      reference = Reference.create!(:authors => 'Dlussky, G.M.',
                                    :title => "Ants of the genus *Formica* L. of Mongolia and northeast Tibet (Hymenoptera, Formicidae)",
                                    :citation => "Annales Zoologici 23: 15-43", :year => '1965a')
      bolton = BoltonReference.new(:authors => 'Dlussky, G.M.', :title_and_citation =>
                                   "Ants of the genus Formica L. of Mongolia and northeast Tibet. Annales Zoologici 23: 15-43", :year => '1965a')

      Bolton::ReferenceMatcher.new.match(bolton).should == reference
    end

    it "should find a match when two entries have similar authors" do
      Reference.create!(:authors => 'abc', :title => "title", :citation => "citation", :year => 'year')
      reference = Reference.create!(:authors => 'abd', :title => "another title", :citation => "another citation", :year => 'year')
      bolton = BoltonReference.new(:authors => 'abd', :title_and_citation => "another title another citation", :year => 'year')

      Bolton::ReferenceMatcher.new.match(bolton).should == reference
    end

    it "should find a match when there is a long enough common suffix (e.g., from journal title, volume and page)" do
      ward = Reference.create! :authors => "Arakelian, G. R.; Dlussky, G. M.", :year => '1991',
                               :title => "Dacetine ants (Hymenoptera: Formicidae) of the USSR. [In Russian.].",
                               :citation => "Zoologicheskii Zhurnal 70(2):149-152."
      bolton = BoltonReference.new :authors => 'Arakelian, G.R. & Dlussky, G.M.', :year => '1991',
                                   :title_and_citation => "Murav'i triby Dacetini SSSR. Zoologicheskii Zhurnal 70 (2): 149-152."
      Bolton::ReferenceMatcher.new.match(bolton).should == ward
    end

    it "should find a match when Ward includes taxon names" do
      ward = Reference.create! :authors => "Dlussky, G. M.; Soyunov, O. S.", :year => "1988",
        :title => "Ants of the genus *Temnothorax* Mayr (Hymenoptera: Formicidae) of the USSR. [In Russian.]",
        :citation => "Izvestiya Akademii Nauk Turkmenskoi SSR. Seriya Biologicheskikh Nauk 1988(4):29-37"
      bolton = BoltonReference.new :authors => "Dlussky, G.M. & Soyunov, O.S.", :year => "1988",
        :title_and_citation => "Murav'i roda Temnothorax Mayr SSSR. Izvestiya Akademii Nauk Turkmenskoi SSR. Seriya Biologicheskikh Nauk 1988 (No. 4): 29-37."
      Bolton::ReferenceMatcher.new.match(bolton).should == ward
    end

    it "should find a match when Ward includes taxon names, as long as one of them is one we know about" do
      ward = Reference.create! :authors => "Dlusski, G. M.; Soyunov, O. S.", :year => "1987",
        :title => "Ants of the genus *Temnothorax* Mayr (Hymenoptera, Chrysidoidea, Vespoidea and Apoidea) of the USSR. [In Russian.]",
        :citation => "Izvestiya Akademii Nauk Turkmenskoi SSR. Seriya Biologicheskikh N."
      bolton = BoltonReference.new :authors => "Dlussky, G.M. & Soyunov, O.S.", :year => "1988",
        :title_and_citation => "Murav'i roda Temnothorax Mayr SSSR. Izvestiya Akademii Nauk Turkmenskoi SSR. Seriya Biologicheskikh Nauk"
      Bolton::ReferenceMatcher.new.match(bolton).should == ward
    end

    it "should find a match when the author and year are the same, and a sufficient number of digits in the title + citation are the same" do
      ward = Reference.create! :authors => 'De Geer, C.', :year => '1778', :title => "Mémoires pour servir à l'histoire des insectes. Tome septième (7)",
        :citation => "Stockholm: Pierre Hesselberg, 950 pp"
      bolton = BoltonReference.new :authors => 'De Geer, C.', :year => '1778', :title_and_citation => "Memoirs pour Servir à l'Histoire des Insectes 7: 950 pp. Stockholm."
      Bolton::ReferenceMatcher.new.match(bolton).should == ward
    end

    it "should mark matches as 'suspect' if the authors and year don't match exactly" do
      ward = Reference.create! :authors => 'De Geer, C.', :year => '1777', :title => "Ants", :citation => "Stockholm: Pierre Hesselberg, 950 pp"
      bolton = BoltonReference.new :authors => 'De Geer, C.', :year => '1778', :title_and_citation => "Ants. Stockholm: Pierre Hesselberg, 950 pp"
      matcher = Bolton::ReferenceMatcher.new
      matcher.match(bolton).should == ward
      matcher.should be_suspect
    end

    it "should find the best match, not just the first match above the threshold" do
      Reference.create! :authors => 'De Geer, C.', :year => '1777', :title => "Ants 2", :citation => "Stockholm: Pierre Hesselberg, 950 pp"
      ward = Reference.create! :authors => 'De Geer, C.', :year => '1777', :title => "Ants 1", :citation => "Stockholm: Pierre Hesselberg, 950 pp"
      bolton = BoltonReference.new :authors => 'De Geer, C.', :year => '1777', :title_and_citation => "Ants 1. Stockholm: Pierre Hesselberg, 950 pp"
      Bolton::ReferenceMatcher.new.match(bolton).should == ward
    end

  end
end
=end
