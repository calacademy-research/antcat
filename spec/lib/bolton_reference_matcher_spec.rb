require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe BoltonReferenceMatcher do
  describe "matching Bolton's references against Ward's" do
    it "should not match an obvious mismatch" do
      Reference.create!(:authors => 'Fisher, B.L.', :title => "My life among the ants", :citation => "Playboy", :year => '2009')
      bolton = BoltonReference.new(:authors => 'Dlussky, G.M.', :title_and_citation =>
                                   "Ants of the genus Formica L. of Mongolia and northeast Tibet. Annales Zoologici 23: 15-43", :year => '1965a')

      BoltonReferenceMatcher.new.match(bolton).should be_nil
    end

    it "should find an exact match" do
      ward = Reference.create!(:authors => 'Dlussky, G.M.',
                               :title => "Ants of the genus Formica L. of Mongolia and northeast Tibet",
                               :citation => "Annales Zoologici 23: 15-43", :year => '1965a')
      bolton = BoltonReference.new(:authors => 'Dlussky, G.M.', :title_and_citation =>
                                    "Ants of the genus Formica L. of Mongolia and northeast Tibet. Annales Zoologici 23: 15-43", :year => '1965a')
      foo = BoltonReferenceMatcher.new
      bar = foo.match(bolton)
      bar.should == ward
    end

    it "should find a match when Ward has markup" do
      reference = Reference.create!(:authors => 'Dlussky, G.M.',
                                    :title => "Ants of the genus *Formica* L. of Mongolia and northeast Tibet",
                                    :citation => "Annales Zoologici 23: 15-43", :year => '1965a')
      bolton = BoltonReference.new(:authors => 'Dlussky, G.M.', :title_and_citation =>
                                   "Ants of the genus Formica L. of Mongolia and northeast Tibet. Annales Zoologici 23: 15-43", :year => '1965a')

      BoltonReferenceMatcher.new.match(bolton).should == reference
    end

    it "should find a match when Ward has extra text" do
      reference = Reference.create!(:authors => 'Dlussky, G.M.',
                                    :title => "Ants of the genus *Formica* L. of Mongolia and northeast Tibet (Hymenoptera, Formicidae)",
                                    :citation => "Annales Zoologici 23: 15-43", :year => '1965a')
      bolton = BoltonReference.new(:authors => 'Dlussky, G.M.', :title_and_citation =>
                                   "Ants of the genus Formica L. of Mongolia and northeast Tibet. Annales Zoologici 23: 15-43", :year => '1965a')

      BoltonReferenceMatcher.new.match(bolton).should == reference
    end

    it "should find a match when two entries have similar authors" do
      Reference.create!(:authors => 'abc', :title => "title", :citation => "citation", :year => 'year')
      reference = Reference.create!(:authors => 'abd', :title => "another title", :citation => "another citation", :year => 'year')
      bolton = BoltonReference.new(:authors => 'abd', :title_and_citation => "another title another citation", :year => 'year')

      BoltonReferenceMatcher.new.match(bolton).should == reference
    end

    it "should find a match when there is a long enough common suffix (e.g., from journal title, volume and page)" do
      ward = Reference.create! :authors => "Arakelian, G. R.; Dlussky, G. M.", :year => '1991',
                               :title => "Dacetine ants (Hymenoptera: Formicidae) of the USSR. [In Russian.].",
                               :citation => "Zoologicheskii Zhurnal 70(2):149-152."
      bolton = BoltonReference.new :authors => 'Arakelian, G.R. & Dlussky, G.M.', :year => '1991',
                                   :title_and_citation => "Murav'i triby Dacetini SSSR. Zoologicheskii Zhurnal 70 (2): 149-152."
      BoltonReferenceMatcher.new.match(bolton).should == ward
    end

    it "should find a match when Ward includes taxon names" do
      ward = Reference.create! :authors => "Dlussky, G. M.; Soyunov, O. S.", :year => "1988",
        :title => "Ants of the genus *Temnothorax* Mayr (Hymenoptera: Formicidae) of the USSR. [In Russian.]",
        :citation => "Izvestiya Akademii Nauk Turkmenskoi SSR. Seriya Biologicheskikh Nauk 1988(4):29-37"
      bolton = BoltonReference.new :authors => "Dlussky, G.M. & Soyunov, O.S.", :year => "1988",
        :title_and_citation => "Murav'i roda Temnothorax Mayr SSSR. Izvestiya Akademii Nauk Turkmenskoi SSR. Seriya Biologicheskikh Nauk 1988 (No. 4): 29-37."
      BoltonReferenceMatcher.new.match(bolton).should == ward
    end

    it "should find a match when the author and year are the same, and a sufficient number of digits in the title + citation are the same" do
      ward = Reference.create! :authors => 'De Geer, C.', :year => '1778', :title => "Mémoires pour servir à l'histoire des insectes. Tome septième (7)",
        :citation => "Stockholm: Pierre Hesselberg, 950 pp"
      bolton = BoltonReference.new :authors => 'De Geer, C.', :year => '1778', :title_and_citation => "Memoirs pour Servir à l'Histoire des Insectes 7: 950 pp. Stockholm."
      BoltonReferenceMatcher.new.match(bolton).should == ward
    end
  end
end
