require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe WardReference do
  describe "parsing the citation" do
    describe "parsing a journal citation" do
      before do
        @reference = Factory(:ward_reference, :citation => 'Behav. Ecol. Sociobiol. 4:163-181.')
      end

      it "should extract the journal title" do
        @reference.parse_citation
        @reference.journal_title.should == 'Behav. Ecol. Sociobiol.'
      end

      it "should extract the journal volume" do
        @reference.parse_citation
        @reference.volume.should == '4'
      end
      it "should extract the beginning page number" do
        @reference.parse_citation
        @reference.start_page.should == '163'
      end
      it "should extract the ending page number" do
        @reference.parse_citation
        @reference.end_page.should == '181'
      end
      it "should recognize it as a journal" do
        @reference.parse_citation
        @reference.kind.should == 'journal'
      end

      describe "parsing a citation with just a single page number" do
        it "should work" do
          reference = Factory(:ward_reference, :citation => "Entomol. Mon. Mag. 92:8.")
          reference.parse_citation
          reference.journal_title.should == 'Entomol. Mon. Mag.'
          reference.volume.should == '92'
          reference.start_page.should == '8'
          reference.end_page.should be_nil
        end
      end

      describe "parsing a citation with an issue number" do
        it "should work" do
          reference = Factory(:ward_reference, :citation => "Entomol. Mon. Mag. 92(32):8.")
          reference.parse_citation
          reference.volume.should == '92'
          reference.issue.should == '32'
          reference.start_page.should == '8'
          reference.end_page.should be_nil
        end
      end

      describe "parsing a citation with a series number" do
        it "should work" do
          reference = Factory(:ward_reference, :citation => 'Ann. Mag. Nat. Hist. (10)8:129-131.')
          reference.parse_citation
          reference.series.should == '10'
          reference.volume.should == '8'
        end
      end

      describe "parsing a citation with series, volume and issue" do
        it "should work" do
          reference = Factory(:ward_reference, :citation => 'Ann. Mag. Nat. Hist. (I)C(xix):129-131.')
          reference.parse_citation
          reference.series.should == 'I'
          reference.volume.should == 'C'
          reference.issue.should == 'xix'
        end
      end
    end

    describe "parsing a book citation" do
      before do
        @reference = Factory(:ward_reference, :citation => 'Melbourne: CSIRO Publications, vii + 70 pp.')
      end

      it "should extract the place of publication" do
        @reference.parse_citation
        @reference.place.should == 'Melbourne'
      end

      it "should extract the publisher" do
        @reference.parse_citation
        @reference.publisher.should == 'CSIRO Publications'
      end
      it "should extract the pagination" do
        @reference.parse_citation
        @reference.pagination.should == 'vii + 70 pp.'
      end
      it "should recognize it as a book" do
        @reference.parse_citation
        @reference.kind.should == 'book'
      end
    end

    describe "parsing a book citation with complicate pagination" do
      it "should work" do
        reference = Factory(:ward_reference, :citation => 'Tokyo: Keishu-sha, 247 pp. + 14 pl. + 4 pp. (index).')
        reference.parse_citation
        reference.place.should == 'Tokyo'
        reference.publisher.should == 'Keishu-sha'
        reference.pagination.should == '247 pp. + 14 pl. + 4 pp. (index).'
        reference.kind.should == 'book'
      end
    end

    describe "parsing a nested citation" do
      describe "without page numbers" do
        it "should work" do
          reference = Factory(:ward_reference, :citation => 'In: Michaelsen, W., Hartmeyer, R. (eds.)  Die Fauna SŸdwest-Australiens. Band I, Lieferung 7.  Jena: Gustav Fischer, pp. 263-310.')
          reference.parse_citation
          reference.kind.should == 'nested'
        end
      end
      describe "with page numbers" do
        it "should work" do
          reference = Factory(:ward_reference, :citation => 'Pp. 191-210 in: Presl, J. S., Presl, K. B.  Deliciae Pragenses, historiam naturalem spectantes. Tome 1.  Pragae: Calve, 244 pp.')
          reference.parse_citation
          reference.kind.should == 'nested'
        end
      end

    end

    describe "parsing an unknown format" do
      it "should consider it an unknown format" do
        reference = Factory(:ward_reference, :citation => 'asdf')
        reference.parse_citation
        reference.kind.should == 'unknown'
      end
    end
  end

  describe "searching" do
    it "should return an empty array if nothing is found for author" do
      Factory(:ward_reference, :authors => 'Bolton')
      WardReference.search(:author => 'foo').should be_empty
    end

    it "should find the reference for a given author if it exists" do
      reference = Factory.create(:ward_reference, :authors => 'Bolton')
      Factory.create(:ward_reference, :authors => 'Fisher')
      WardReference.search(:author => 'Bolton').should == [reference]
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
      reference = Factory.create(:ward_reference, :authors => 'Fisher', :year => 1996)
      WardReference.search(:start_year => '1996', :end_year => '1996', :author => 'Fisher').should == [reference]
    end

    describe "searching by year" do
      before do
        Factory.create(:ward_reference, :year => 1994)
        Factory.create(:ward_reference, :year => 1995)
        Factory.create(:ward_reference, :year => 1996)
        Factory.create(:ward_reference, :year => 1997)
        Factory.create(:ward_reference, :year => 1998)
      end

      it "should return an empty array if nothing is found for year" do
        WardReference.search(:start_year => '1992', :end_year => '1993').should be_empty
      end

      it "should find entries less than or equal to the end year" do
        WardReference.search(:end_year => '1995').map(&:numeric_year).should =~ [1994, 1995]
      end

      it "should find entries equal to or greater than the start year" do
        WardReference.search(:start_year => '1995').map(&:numeric_year).should =~ [1995, 1996, 1997, 1998]
      end

      it "should find entries in between the start year and the end year (inclusive)" do
        WardReference.search(:start_year => '1995', :end_year => '1996').map(&:numeric_year).should =~ [1995, 1996]
      end

      it "should find references in the year of the end range, even if they have extra characters" do
        Factory.create(:ward_reference, :year => '2004.', :year => 2004)
        WardReference.search(:start_year => '2004', :end_year => '2004').map(&:numeric_year).should =~ [2004]
      end

      it "should find references in the year of the start year, even if they have extra characters" do
        Factory.create(:ward_reference, :year => '2004.', :year => 2004)
        WardReference.search(:start_year => '2004', :end_year => '2004').map(&:numeric_year).should =~ [2004]
      end

    end
    
    describe "sorting search results" do
      it "should sort by author plus year plus letter" do
        fisher1910b = Factory.create :ward_reference, :authors => 'Fisher', :year => '1910b'
        wheeler1874 = Factory.create :ward_reference, :authors => 'Wheeler', :year => '1874'
        fisher1910a = Factory.create :ward_reference, :authors => 'Fisher', :year => '1910a'

        results = WardReference.search

        results.should == [fisher1910a, fisher1910b, wheeler1874]
      end
    end

    describe "searching by journal" do
      it "should find by journal" do
        reference = Factory.create(:ward_reference, :citation => "Mathematica 1:2")
        WardReference.search(:journal => 'Mathematica').should == [reference]
      end
      it "should only do an exact match" do
        Factory.create(:ward_reference, :citation => "Mathematica 1:2")
        WardReference.search(:journal => 'Math').should be_empty
      end
    end

  end

  describe "parsing after editing" do
    it "should parse out the numeric year" do
      reference = Factory(:ward_reference, :year => '1910a', :numeric_year => 1910)
      reference.update_attribute(:year, '2000a')
      reference.numeric_year.should == 2000
    end
    it "should parse out the journal title" do
      reference = Factory(:ward_reference, :citation => 'Ecology Letters 12:324-333.', :journal_title => 'Ecology Letters')
      reference.update_attribute(:citation, 'Playboy 3:1-5')
      reference.journal_title.should == 'Playboy'
    end
  end
  describe "parsing after creating" do
    it "should parse out the numeric year" do
      reference = Factory.create(:ward_reference, :year => '1910a')
      reference.numeric_year.should == 1910
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
end
