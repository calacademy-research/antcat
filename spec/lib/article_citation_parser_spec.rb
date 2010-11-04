require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ArticleCitationParser do
  it "should handle a missing citation" do
    ['', nil].each do |citation|
      ArticleCitationParser.parse(citation).should be_nil
    end
  end

  it "should quietly return if the citation isn't for an article" do
    ArticleCitationParser.parse('Dresden.').should be_nil
  end

  it "should extract article, issue and journal information" do
    ArticleCitationParser.parse('Behav. Ecol. Sociobiol. 4:163-181.').should ==
      {:article => {:journal => 'Behav. Ecol. Sociobiol.', :series_volume_issue => '4', :pagination => '163-181'}}
  end

  it "should parse a citation with just a single page issue" do
    ArticleCitationParser.parse("Entomol. Mon. Mag. 92:8.").should ==
      {:article => {:journal => 'Entomol. Mon. Mag.', :series_volume_issue => '92', :pagination => '8'}}
  end

  it "should parse a citation with an issue issue" do
    ArticleCitationParser.parse("Entomol. Mon. Mag. 92(32):8.").should ==
      {:article => {:journal => 'Entomol. Mon. Mag.', :series_volume_issue => '92(32)', :pagination => '8'}}
  end

  it "should parse a citation with a series issue" do
    ArticleCitationParser.parse('Ann. Mag. Nat. Hist. (10)8:129-131.').should ==
      {:article => {:journal => 'Ann. Mag. Nat. Hist.', :series_volume_issue => '(10)8', :pagination => '129-131'}}
  end

  it "should parse a citation with series, volume and issue" do
    ArticleCitationParser.parse('Ann. Mag. Nat. Hist. (I)C(xix):129-131.').should ==
      {:article => {:journal => 'Ann. Mag. Nat. Hist.', :series_volume_issue => '(I)C(xix)', :pagination => '129-131'}}
  end

  describe "parsing fields from series_volume_issue" do
    it "can parse out volume and issue" do
      ArticleCitationParser.get_series_volume_issue_parts("92(32)").should == {:volume => '92', :issue => '32'}
    end
    it "can parse out the series and volume" do
      ArticleCitationParser.get_series_volume_issue_parts("(10)8").should == {:series => '10', :volume => '8'}
    end
    it "can parse out series, volume and issue" do
      ArticleCitationParser.get_series_volume_issue_parts('(I)C(xix)').should == {:series => 'I', :volume => 'C', :issue => 'xix'}
    end
  end

  describe "parsing fields from pagination" do
    it "should parse beginning and ending page numbers" do
      ArticleCitationParser.get_page_parts('163-181').should == {:start => '163', :end => '181'}
    end
    it "should parse just a single page number" do
      ArticleCitationParser.get_page_parts('8').should == {:start => '8'}
    end
  end

end
