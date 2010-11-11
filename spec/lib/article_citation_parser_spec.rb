require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ArticleCitationParser do
  it "should handle a missing citation" do
    ['', nil].each do |citation|
      ArticleCitationParser.parse(citation, false).should be_nil
    end
  end

  it "should quietly return if the citation isn't for an article" do
    ArticleCitationParser.parse('Dresden.', false).should be_nil
  end

  describe "different behavior when possibly embedded (i.e., preceded by a title)" do
    it 'should recognize an unembedded article citation' do
      ArticleCitationParser.parse('Science 1:2', false).should have_key(:article)
    end
    it 'should recognize an embedded article citation' do
      ArticleCitationParser.parse('Science 1:2', true).should have_key(:article)
    end
    it 'should recognize an unembedded article citation whose journal has periods' do
      ArticleCitationParser.parse('Doc. Science 1:2', false).should have_key(:article)
    end
    it 'should not recognize a possibly embedded article citation whose journal has periods' do
      ArticleCitationParser.parse('Doc. Science 1:2', true).should be_false
    end
    it 'should recognize a possibly embedded article citation whose journal has periods if the journal exists' do
      Journal.create! :name => 'Doc. Science'
      ArticleCitationParser.parse('Doc. Science 1:2', true).should have_key(:article)
    end
    it 'should recognize a possibly embedded article citation whose journal has periods if the journal begins with a common word' do
      Journal.create! :name => 'Journal of Ent. Science'
      ArticleCitationParser.parse('Journal of Ent. Science 1:2', true).should have_key(:article)
    end
  end

  it "should extract article, issue and journal information" do
    ArticleCitationParser.parse('Science 4:163-181.', false).should ==
      {:article => {:journal => 'Science', :series_volume_issue => '4', :pagination => '163-181'}}
  end

  it "should parse a citation with just a single page issue" do
    ArticleCitationParser.parse("Science 92:8.", false).should ==
      {:article => {:journal => 'Science', :series_volume_issue => '92', :pagination => '8'}}
  end

  it "should parse a citation with an issue" do
    ArticleCitationParser.parse("Science 92(32):8.", false).should ==
      {:article => {:journal => 'Science', :series_volume_issue => '92(32)', :pagination => '8'}}
  end

  it "should parse a citation with a series issue" do
    ArticleCitationParser.parse('Science (10)8:129-131.', false).should ==
      {:article => {:journal => 'Science', :series_volume_issue => '(10)8', :pagination => '129-131'}}
  end

  it "should parse a citation with series, volume and issue" do
    ArticleCitationParser.parse('Science (I)C(xix):129-131.', false).should ==
      {:article => {:journal => 'Science', :series_volume_issue => '(I)C(xix)', :pagination => '129-131'}}
  end

  it "should recognize that if the first letter of the citation is a lowercase letter, then something's wrong" do
    ArticleCitationParser.parse('gesammelt von Prof. Herm. v. Ihering, Dr. Lutz, Dr. Fiebrig, etc. Verhandlungen der Kaiserlich-Königlichen Zoologisch-Botanischen Gesellschaft in Wien 58:340-41', false).should be_nil
  end

  describe "when there's a space after the colon" do
    it "should be able to parse it" do
      ArticleCitationParser.parse('Zootaxa 1929(1): 1-37', false).should ==
        {:article => {:journal => 'Zootaxa', :series_volume_issue => '1929(1)', :pagination => '1-37'}}
    end
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
