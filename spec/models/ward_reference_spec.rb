require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe WardReference do

  describe "parsing authors" do
    it "should parse a single author into a one-element array" do
      reference = Factory(:ward_reference, :authors => 'Fisher, B.L.')
      reference.parse_authors.should == ['Fisher, B.L.']
    end
    it "should parse multiple authors" do
      reference = Factory(:ward_reference, :authors => 'Fisher, B.L.; Wheeler, W.M.')
      reference.parse_authors.should == ['Fisher, B.L.', 'Wheeler, W.M.']
    end
  end

  describe "parsing the citation" do
    describe "parsing a journal citation" do
      it "should extract article, issue and journal information" do
        reference = Factory(:ward_reference, :citation => 'Behav. Ecol. Sociobiol. 4:163-181.')
        reference.parse_citation.should == 
          {:article => {
            :issue => {:journal => {:title => 'Behav. Ecol. Sociobiol.'}, :series => nil, :volume => '4', :issue => nil},
            :start_page => '163', :end_page => '181'}}
      end

      it "should parse a citation with just a single page issue" do
        reference = Factory(:ward_reference, :citation => "Entomol. Mon. Mag. 92:8.")
        reference.parse_citation.should == 
          {:article => {
            :issue => {:journal => {:title => 'Entomol. Mon. Mag.'}, :series => nil, :volume => '92', :issue => nil},
            :start_page => '8', :end_page => nil}}
      end

      it "should parse a citation with an issue issue" do
        reference = Factory(:ward_reference, :citation => "Entomol. Mon. Mag. 92(32):8.")
        reference.parse_citation.should == 
          {:article => {
            :issue => {:journal => {:title => 'Entomol. Mon. Mag.'}, :series => nil, :volume => '92', :issue => '32'},
            :start_page => '8', :end_page => nil}}
      end

      it "should parse a citation with a series issue" do
        reference = Factory(:ward_reference, :citation => 'Ann. Mag. Nat. Hist. (10)8:129-131.')
        reference.parse_citation.should == 
          {:article => {
            :issue => {:journal => {:title => 'Ann. Mag. Nat. Hist.'}, :series => '10', :volume => '8', :issue => nil},
            :start_page => '129', :end_page => '131'}}
      end

      it "should parse a citation with series, volume and issue" do
        reference = Factory(:ward_reference, :citation => 'Ann. Mag. Nat. Hist. (I)C(xix):129-131.')
        reference.parse_citation.should == 
          {:article => {
            :issue => {:journal => {:title => 'Ann. Mag. Nat. Hist.'}, :series => 'I', :volume => 'C', :issue => 'xix'},
            :start_page => '129', :end_page => '131'}}
      end
    end

    describe "parsing a book citation" do
      it "should extract the place, pagination and publisher" do
        reference = Factory(:ward_reference, :citation => 'Melbourne: CSIRO Publications, vii + 70 pp.')
        reference.parse_citation.should ==
          {:book => {
            :publisher => {:name => 'CSIRO Publications', :place => 'Melbourne'},
            :pagination => 'vii + 70 pp.'}}
      end

      it "should parse a book citation with complicate pagination" do
        reference = Factory(:ward_reference, :citation => 'Tokyo: Keishu-sha, 247 pp. + 14 pl. + 4 pp. (index).')
        reference.parse_citation.should ==
          {:book => {
            :publisher => {:name =>  'Keishu-sha', :place => 'Tokyo'},
            :pagination => '247 pp. + 14 pl. + 4 pp. (index).'}}
      end
    end

    describe "parsing a nested citation" do
      it "should handle parsing with no page numbers" do
        reference = Factory(:ward_reference, :citation => 'In: Michaelsen, W., Hartmeyer, R. (eds.)  Die Fauna SŸdwest-Australiens. Band I, Lieferung 7.  Jena: Gustav Fischer, pp. 263-310.')
        reference.parse_citation.should ==
          {:nested => {:citation => 'In: Michaelsen, W., Hartmeyer, R. (eds.)  Die Fauna SŸdwest-Australiens. Band I, Lieferung 7.  Jena: Gustav Fischer, pp. 263-310.'}}
      end
      it "should handle parsing with page numbers" do
        reference = Factory(:ward_reference, :citation => 'Pp. 191-210 in: Presl, J. S., Presl, K. B.  Deliciae Pragenses, historiam naturalem spectantes. Tome 1.  Pragae: Calve, 244 pp.')
        reference.parse_citation.should ==
          {:nested => {:citation => 'Pp. 191-210 in: Presl, J. S., Presl, K. B.  Deliciae Pragenses, historiam naturalem spectantes. Tome 1.  Pragae: Calve, 244 pp.'}}
      end
    end

    describe "parsing an unknown format" do
      it "should consider it an unknown format" do
        reference = Factory(:ward_reference, :citation => 'asdf')
        reference.parse_citation
        reference.parse_citation.should == {:unknown => {:citation => 'asdf'}}
      end
    end
  end

  describe "importing to Reference" do
    it "after creation, it passes its parsed components to Reference and gets back its Reference" do
      reference = Factory(:reference)
      Reference.should_receive(:import).with({:year => 1910, :authors => ['Fisher, B.L.'], :title => 'Ants',
        :article => {
          :issue => {:journal => {:title => 'Ecology Letters'}, :series => nil, :volume => '12', :issue => nil},
          :start_page => '324', :end_page => '333'}}).and_return reference
      ward = WardReference.create!(:authors => 'Fisher, B.L.', :citation => 'Ecology Letters 12:324-333', :year => '1910d',
                            :title => 'Ants',
                            :public_notes => 'This is public', :editor_notes => 'Editor notes',
                            :taxonomic_notes => 'Taxonomic notes', :cite_code => '32', :possess => 'PSW', :date => '19100201')
      ward.reload.reference.should == reference
    end

    it "after editing, it passes its parsed components to Reference" do
      reference = Factory(:reference)
      Reference.should_receive(:import).and_return reference
      ward = WardReference.create!(:authors => 'Fisher, B.L.', :citation => 'Ecology Letters 12:324-333', :year => '1910d',
                            :title => 'Ants',
                            :public_notes => 'This is public', :editor_notes => 'Editor notes',
                            :taxonomic_notes => 'Taxonomic notes', :cite_code => '32', :possess => 'PSW', :date => '19100201')
      reference.should_receive(:import).with({:authors => ['Fisher, B.L.'], :year => 2010, :title => 'Ants',
        :article => {
          :issue => {:journal => {:title => 'Ecology Letters'}, :series => nil, :volume => '12', :issue => nil},
          :start_page => '324', :end_page => '333'}})
      ward.update_attribute(:year, '2010')
    end
  end

  describe "validations" do
    it "should allow valid contents" do
      reference = WardReference.create(:authors => 'Ward, P.S.', :citation => 'asdf', :year => '1229', :title => 'asdf')
      reference.should be_valid
    end
    it "should not allow blank authors" do
      reference = WardReference.create(:authors => nil, :citation => 'asdf', :year => '1229', :title => 'asdf')
      reference.should_not be_valid
    end
    it "should not allow blank citation" do
      reference = WardReference.create(:authors => 'asdf', :citation => nil, :year => '1229', :title => 'asdf')
      reference.should_not be_valid
    end
    it "should not allow blank year" do
      reference = WardReference.create(:authors => 'asdaf', :citation => 'asdf', :year => nil, :title => 'asdf')
      reference.should_not be_valid
    end
    it "should not allow blank title" do
      reference = WardReference.create(:authors => 'asdaf', :citation => 'asdf', :year => '323', :title => nil)
      reference.should_not be_valid
    end
  end

  describe "string representation" do
    it "should be readable and informative" do
      reference = WardReference.new(:authors => "Abdul-Rassoul, M. S.", :year => "1978", :title => 'Records of insect collection',
                                :citation => 'Bull. Nat. Hist. Res. Cent. Univ. Baghdad 7(2):1-6')
      reference.to_s.should == "Abdul-Rassoul, M. S. 1978. Records of insect collection. Bull. Nat. Hist. Res. Cent. Univ. Baghdad 7(2):1-6."
    end
  end

  describe "searching" do
    it "should return an empty array if nothing is found for author" do
      Factory(:ward_reference, :authors => 'Bolton')
      WardReference.search(:author => 'foo').should be_empty
    end

    it "should find the reference for a given author if it exists" do
      reference = Factory(:ward_reference, :authors => 'Bolton')
      Factory(:ward_reference, :authors => 'Fisher')
      WardReference.search(:author => 'Bolton').should == [reference]
    end

    it "should find the reference for a given author prefix if it exists" do
      reference = Factory(:ward_reference, :authors => 'Bolton')
      Factory(:ward_reference, :authors => 'Fisher')
      WardReference.search(:author => 'Bolt').should == [reference]
    end

    it "should return an empty array if nothing is found for a given year and author" do
      Factory(:ward_reference, :authors => 'Bolton', :year => 2010)
      Factory(:ward_reference, :authors => 'Bolton', :year => 1995)
      Factory(:ward_reference, :authors => 'Fisher', :year => 2011)
      Factory(:ward_reference, :authors => 'Fisher', :year => 1996)
      WardReference.search(:start_year => '2012', :end_year => '2013', :author => 'Fisher').should be_empty
    end

    it "should return the one reference for a given year and author" do
      Factory(:ward_reference, :authors => 'Bolton', :year => 2010)
      Factory(:ward_reference, :authors => 'Bolton', :year => 1995)
      Factory(:ward_reference, :authors => 'Fisher', :year => 2011)
      reference = Factory(:ward_reference, :authors => 'Fisher', :year => 1996)
      WardReference.search(:start_year => '1996', :end_year => '1996', :author => 'Fisher').should == [reference]
    end

    describe "searching by year" do
      before do
        Factory(:ward_reference, :year => 1994)
        Factory(:ward_reference, :year => 1995)
        Factory(:ward_reference, :year => 1996)
        Factory(:ward_reference, :year => 1997)
        Factory(:ward_reference, :year => 1998)
      end

      it "should return an empty array if nothing is found for year" do
        WardReference.search(:start_year => '1992', :end_year => '1993').should be_empty
      end

      it "should find entries less than or equal to the end year" do
        WardReference.search(:end_year => '1995').map(&:year).should =~ ['1994', '1995']
      end

      it "should find entries equal to or greater than the start year" do
        WardReference.search(:start_year => '1995').map(&:year).should =~ ['1995', '1996', '1997', '1998']
      end

      it "should find entries in between the start year and the end year (inclusive)" do
        WardReference.search(:start_year => '1995', :end_year => '1996').map(&:year).should =~ ['1995', '1996']
      end

      it "should find references in the year of the end range, even if they have extra characters" do
        Factory(:ward_reference, :year => '2004.', :year => 2004)
        WardReference.search(:start_year => '2004', :end_year => '2004').map(&:year).should =~ ['2004']
      end

      it "should find references in the year of the start year, even if they have extra characters" do
        Factory(:ward_reference, :year => '2004.', :year => 2004)
        WardReference.search(:start_year => '2004', :end_year => '2004').map(&:year).should =~ ['2004']
      end

    end
    
    describe "sorting search results" do
      it "should sort by author plus year plus letter" do
        fisher1910b = Factory(:ward_reference, :authors => 'Fisher', :year => '1910b')
        wheeler1874 = Factory(:ward_reference, :authors => 'Wheeler', :year => '1874')
        fisher1910a = Factory(:ward_reference, :authors => 'Fisher', :year => '1910a')

        results = WardReference.search

        results.should == [fisher1910a, fisher1910b, wheeler1874]
      end
    end

    describe "searching by journal" do
      it "should find by journal" do
        reference = Factory(:ward_reference, :citation => "Mathematica 1:2")
        Factory(:ward_reference, :citation => "Ants Monthly 1:3")
        WardReference.search(:journal => 'Mathematica').should == [reference]
      end
      it "should only do an exact match" do
        Factory(:ward_reference, :citation => "Mathematica 1:2")
        WardReference.search(:journal => 'Math').should be_empty
      end
    end

  end
end
