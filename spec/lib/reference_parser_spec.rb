require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ReferenceParser do
  before do
    @parser = ReferenceParser.new
  end

  describe "parsing authors" do
    it "should parse a single author into a one-element array" do
      @parser.parse_authors('Fisher, B.L.').should == ['Fisher, B.L.']
    end
    it "should parse multiple authors" do
      @parser.parse_authors('Fisher, B.L.; Wheeler, W.M.').should == ['Fisher, B.L.', 'Wheeler, W.M.']
    end
  end

  describe "parsing a article citation" do
    it "should extract article, issue and journal information" do
      @parser.parse_article_citation('Behav. Ecol. Sociobiol. 4:163-181.').should ==
        {:article => {:journal => 'Behav. Ecol. Sociobiol.', :series_volume_issue => '4', :pagination => '163-181'}}
    end

    it "should parse a citation with just a single page issue" do
      @parser.parse_article_citation("Entomol. Mon. Mag. 92:8.").should ==
        {:article => {:journal => 'Entomol. Mon. Mag.', :series_volume_issue => '92', :pagination => '8'}}
    end

    it "should parse a citation with an issue issue" do
      @parser.parse_article_citation("Entomol. Mon. Mag. 92(32):8.").should ==
        {:article => {:journal => 'Entomol. Mon. Mag.', :series_volume_issue => '92(32)', :pagination => '8'}}
    end

    it "should parse a citation with a series issue" do
      @parser.parse_article_citation('Ann. Mag. Nat. Hist. (10)8:129-131.').should ==
        {:article => {:journal => 'Ann. Mag. Nat. Hist.', :series_volume_issue => '(10)8', :pagination => '129-131'}}
    end

    it "should parse a citation with series, volume and issue" do
      @parser.parse_article_citation('Ann. Mag. Nat. Hist. (I)C(xix):129-131.').should ==
        {:article => {:journal => 'Ann. Mag. Nat. Hist.', :series_volume_issue => '(I)C(xix)', :pagination => '129-131'}}
    end
  end

  describe "parsing a CD-ROM citation" do
    it "should return nil if it doesn't seem to be a CD-ROM citation" do
      @parser.parse_cd_rom_citation('Science 1:2').should be_nil
    end

    it "should handle a CD-ROM citation" do
      @parser.parse_cd_rom_citation('Cambridge, Mass.: Harvard University Press, CD-ROM.').should ==
        {:other => 'Cambridge, Mass.: Harvard University Press, CD-ROM'}
    end
  end

  describe "parsing a book citation" do
    it "should return nil if it doesn't seem to be a book citation" do
      @parser.parse_book_citation('Science 1:2').should be_nil
    end

    it "should extract the place, pagination and publisher" do
      @parser.parse_book_citation('Melbourne: CSIRO Publications, vii + 70 pp.').should == (
        {:book => {:publisher => {:name => 'CSIRO Publications', :place => 'Melbourne'}, :pagination => 'vii + 70 pp.'}}
      )
    end

    it "should handle other variations in pagination" do
      ['1 p., 5 maps',
        '12 + 532 pp.',
        '24 pp. 24 pls.',
        '247 pp. + 14 pl. + 4 pp. (index)',
        '312 + (posthumous section) 95 pp.',
        '5-187 + i-viii pp.',
        '5 maps',
        '8 pls., 84 pp.',
        'i-ii, 279-655',
        'xi',
        '93-114, 121'
      ].each do |pagination|
        @parser.parse_book_citation("Tokyo: Keishu-sha, #{pagination}").should ==(
          {:book => {:publisher => {:name =>  'Keishu-sha', :place => 'Tokyo'}, :pagination => pagination}}
        )
      end
    end

    it "should handle a publisher with a comma in its name" do
      @parser.parse_book_citation('New York: Little, Brown, vii + 70 pp.').should == 
        {:book => {:publisher => {:name => 'Little, Brown', :place => 'New York'}, :pagination => 'vii + 70 pp.'}}
    end

    it "should handle a publisher with 'i' as a word in its name" do
      @parser.parse_book_citation('Warszawa: Panstwowe Wydawnictwo Rolnicze i Lesne, 55 pp.').should ==
        {:book => {:publisher => {:name => 'Panstwowe Wydawnictwo Rolnicze i Lesne', :place => 'Warszawa'}, :pagination => '55 pp.'}}
    end
    
    it "should handle a publisher with a number in it" do
      @parser.parse_book_citation(
        'Perth, Australia: Curtin University School of Environmental Biology (Bulletin No. 18), xii + 75 pp.'
      ).should ==
        {:book => {:publisher => {:name => 'Curtin University School of Environmental Biology (Bulletin No. 18)', :place => 'Perth, Australia'},
         :pagination => 'xii + 75 pp.'}}
    end
    
  end

  describe "parsing a citation" do
    it "should simply return nil if there's no citation" do
      @parser.parse_citation(nil).should be_nil
    end
  end

  describe "parsing an unknown format" do
    it "should consider it an 'other' reference" do
      @parser.parse_unknown_citation('asdf').should == {:other => 'asdf'}
    end
    it "should remove the period from the end" do
      @parser.parse_unknown_citation('asdf.').should == {:other => 'asdf'}
    end
  end

  describe "parsing a nested citation" do
    it "should return nil if it doesn't seem to be a nested citation" do
      @parser.parse_nested_citation('Science 1:2').should be_nil
    end

    describe "parsing a nested citation" do
      #it "should handle parsing with no page numbers" do
        #@parser.parse_nested_citation(
          #'In: Michaelsen, W., Hartmeyer, R. (eds.)  Die Fauna Sdwest-Australiens. Band I, Lieferung 7.  Jena: Gustav Fischer, pp. 263-310.').
          #should ==
          #{:reference => {:authors => 'Michaelsen, W., Hartmeyer, R. (eds.)', :title => 'Die Fauna Sdwest-Australiens. Band I, Lieferung 7.',
           #:publisher => {:name => 'Gustav Fischer', :place => 'Jena'}, :pagination => 'pp. 263-310'}}
      #end

      #it "should handle parsing with page numbers" do
        #@parser.parse_nested_citation(
          #'Pp. 191-210 in: Presl, J. S., Presl, K. B.  Deliciae Pragenses, historiam naturalem spectantes. Tome 1.  Pragae: Calve, 244 pp.').
          #should ==
          #'Pp. 191-210 in: Presl, J. S., Presl, K. B.  Deliciae Pragenses, historiam naturalem spectantes. Tome 1.  Pragae: Calve, 244 pp'
      #end

      #it "should handle parsing with page numbers when 'in' isn't followed by a colon" do
        #@parser.parse_nested_citation(
          #'Pp. 161-164 in Ganzhorn, J. U., Sorg, J.-P. (eds.) Ecology and economy of a tropical dry forest in Madagascar. Primate Report 46-1. Gttingen: German Primate Center (DPZ), 382 pp.').should ==
          #'Pp. 161-164 in Ganzhorn, J. U., Sorg, J.-P. (eds.) Ecology and economy of a tropical dry forest in Madagascar. Primate Report 46-1. Gttingen: German Primate Center (DPZ), 382 pp'
      #end

    end
  end
end
