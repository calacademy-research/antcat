require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ReferenceParser do
  describe 'parsing' do
    it 'should work' do
      ReferenceParser.parse('Mayer, D.M. 1970. Ants. Psyche 1:2').should == {
        :authors => ['Mayer, D.M.'],
        :year => '1970',
        :title => 'Ants',
        :article => {
          :journal => 'Psyche',
          :series_volume_issue => '1',
          :pagination => '2',
        }
      }
    end
  end

  describe "parsing authors" do
    it "should distinguish between an author name and a title" do
      string = 'Ward, P.S. Ants.'
      parts = ReferenceParser.parse_authors string
      parts.should == {:authors => ['Ward, P.S.']}
      string.should == 'Ants.'
    end
  end

  describe "parsing a article citation" do
    it "should handle a missing citation" do
      ['', nil].each do |citation|
        ReferenceParser.parse_article_citation(citation).should be_nil
      end
    end

    it "should quietly return if the citation isn't for an article" do
      ReferenceParser.parse_article_citation('Dresden.').should be_nil
    end

    it "should extract article, issue and journal information" do
      ReferenceParser.parse_article_citation('Behav. Ecol. Sociobiol. 4:163-181.').should ==
        {:article => {:journal => 'Behav. Ecol. Sociobiol.', :series_volume_issue => '4', :pagination => '163-181'}}
    end

    it "should parse a citation with just a single page issue" do
      ReferenceParser.parse_article_citation("Entomol. Mon. Mag. 92:8.").should ==
        {:article => {:journal => 'Entomol. Mon. Mag.', :series_volume_issue => '92', :pagination => '8'}}
    end

    it "should parse a citation with an issue issue" do
      ReferenceParser.parse_article_citation("Entomol. Mon. Mag. 92(32):8.").should ==
        {:article => {:journal => 'Entomol. Mon. Mag.', :series_volume_issue => '92(32)', :pagination => '8'}}
    end

    it "should parse a citation with a series issue" do
      ReferenceParser.parse_article_citation('Ann. Mag. Nat. Hist. (10)8:129-131.').should ==
        {:article => {:journal => 'Ann. Mag. Nat. Hist.', :series_volume_issue => '(10)8', :pagination => '129-131'}}
    end

    it "should parse a citation with series, volume and issue" do
      ReferenceParser.parse_article_citation('Ann. Mag. Nat. Hist. (I)C(xix):129-131.').should ==
        {:article => {:journal => 'Ann. Mag. Nat. Hist.', :series_volume_issue => '(I)C(xix)', :pagination => '129-131'}}
    end
  end

  describe "parsing a CD-ROM citation" do
    it "should return nil if it doesn't seem to be a CD-ROM citation" do
      ReferenceParser.parse_cd_rom_citation('Science 1:2').should be_nil
    end

    it "should handle a CD-ROM citation" do
      ReferenceParser.parse_cd_rom_citation('Cambridge, Mass.: Harvard University Press, CD-ROM.').should ==
        {:other => 'Cambridge, Mass.: Harvard University Press, CD-ROM'}
    end
  end

  describe "parsing a citation" do
    it "should simply return an empty hash if there's no citation" do
      ['', nil].each {|citation| ReferenceParser.parse_citation(citation).should be_nil}
    end
  end

  describe "parsing an unknown format" do
    it "should consider it an 'other' reference" do
      ReferenceParser.parse_unknown_citation('asdf').should == {:other => 'asdf'}
    end
    it "should remove the period from the end" do
      ReferenceParser.parse_unknown_citation('asdf.').should == {:other => 'asdf'}
    end
  end

  describe "parsing a nested citation" do
    it "should delegate to the NestedParser" do
      NestedParser.should_receive(:parse).with(
        'Pp. 191-210 in: Presl, J. S., Presl, K. B.  Deliciae Pragenses, historiam naturalem spectantes. Tome 1.  Pragae: Calve, 244 pp.')
      ReferenceParser.parse_citation(
        'Pp. 191-210 in: Presl, J. S., Presl, K. B.  Deliciae Pragenses, historiam naturalem spectantes. Tome 1.  Pragae: Calve, 244 pp.')
    end
  end
end
