require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TitleAndCitationParser do
  before :all do
    Factory :place, :name => 'New York'
    Factory :place, :name => 'Cambridge'
  end

  it "should extract a simple title and reference from book reference" do
    string = "Ants. Cambridge:Harvard, 320 pp."
    TitleAndCitationParser.parse(string).should == {
      :title => 'Ants',
      :citation => {
        :book => {
          :publisher => {:name => 'Harvard', :place => 'Cambridge'},
          :pagination => '320 pp.'}}}
  end

  it "should extract a simple title from an article reference" do
    string = "Ants. Psyche 30:1"
    TitleAndCitationParser.parse(string).should == {
      :title => 'Ants',
      :citation => {
        :article => {
          :journal => 'Psyche',
          :series_volume_issue => '30',
          :pagination => '1'}}}
  end

  describe "nested references" do
    it "should extract a simple title followed by 'In:'" do
      string = "Ants. In: Ward, P.S. Ants. New York:Wiley, 32 pp."
      TitleAndCitationParser.parse(string).should == {
        :title => 'Ants',
        :citation => {
          :nested => {
            :pages_in => 'In:',
            :authors => ['Ward, P.S.'],
            :authors_role => '',
            :title => 'Ants',
            :book => {
              :publisher => {:name => 'Wiley', :place => 'New York'},
              :pagination => '32 pp.'}}}}
    end

    it "should extract a simple title followed by a more complicated pages_in" do
      string = "Ants. Pp. 32, 4, 5 in Ward, P.S. Ants. New York:Wiley, 32 pp."
      TitleAndCitationParser.parse(string).should == {
        :title => 'Ants',
        :citation => {
          :nested => {
            :pages_in => 'Pp. 32, 4, 5 in',
            :authors => ['Ward, P.S.'],
            :authors_role => '',
            :title => 'Ants',
            :book => {
              :publisher => {:name => 'Wiley', :place => 'New York'},
              :pagination => '32 pp.'}}}}
    end

    it "should extract a simple title followed by a double nested citation" do
      string = "Ants. Pp. 32, 4, 5 in Ward, P.S. Ants. In: Bolton, B. More ants. New York:Wiley, 32 pp."
      TitleAndCitationParser.parse(string).should == {
        :title => 'Ants',
        :citation => {
          :nested => {
            :pages_in => 'Pp. 32, 4, 5 in',
            :authors => ['Ward, P.S.'],
            :authors_role => '',
            :title => 'Ants',
            :nested => {
              :pages_in => 'In:',
              :authors => ['Bolton, B.'],
              :authors_role => '',
              :title => 'More ants',
              :book => {
                :publisher => {:name => 'Wiley', :place => 'New York'},
                :pagination => '32 pp.'}}}}}
    end

    it "should not find 'in' in the middle of a title" do
      string = "Ants in Madagascar. New York:Wiley, 32 pp."
      TitleAndCitationParser.parse(string)[:title].should == 'Ants in Madagascar'
    end
  end

  describe "titles with periods in them" do

    it "should work when the following citation is nested" do
      string = "Ants of St. Croix. In: Ward, P.S. Ants. New York:Wiley, 32 pp."
      TitleAndCitationParser.parse(string).should == {
        :title => 'Ants of St. Croix',
        :citation => {
          :nested => {
            :pages_in => 'In:',
            :authors => ['Ward, P.S.'],
            :authors_role => '',
            :title => 'Ants',
            :book => {
              :publisher => {:name => 'Wiley', :place => 'New York'},
              :pagination => '32 pp.'}}}}
    end

    ['Abhandlungen', 'Acta', 'Actes', 'Anales', 'Annalen', 'Annales', 'Annali', 'Annals', 'Archives', 'Archivos', 'Arquivos',
     'Boletim', 'Boletin', 'Bollettino', 'Bulletin', 'Izvestiya', 'Journal', 'Memoires', 'Memoirs', 'Memorias', 'Memorie',
     'Mitteilungen', 'Occasional Papers'].each do |word|
      it "should find the title when the journal name starts with '#{word}'" do
        string = "Dodech. Ants. #{word} 32:3"
        TitleAndCitationParser.parse(string).should == {
          :title => 'Dodech. Ants',
          :citation => {
            :article => {
              :journal => word,
              :series_volume_issue => '32',
              :pagination => '3'}}}
      end
     end

    it "should find the title when the journal name is already known" do
      Journal.create! :name => 'Science'
      string = "Dodech. Ants. Science 32:3"
      TitleAndCitationParser.parse(string).should == {
        :title => 'Dodech. Ants',
        :citation => {
          :article => {
            :journal => 'Science',
            :series_volume_issue => '32',
            :pagination => '3'}}}
    end

    it "should find the title when the place name is already known" do
      Place.create! :name => 'Las Vegas'
      string = "Dodech. Ants. Las Vegas:Barnes, 32 pp."
      TitleAndCitationParser.parse(string).should == {
        :title => 'Dodech. Ants',
        :citation => {
          :book => {
            :publisher => {:name => 'Barnes', :place => 'Las Vegas'},
            :pagination => '32 pp.'}}}
    end

    it "should not be fooled by a string that merely starts with the name of a journal" do
      Journal.create! :name => 'Science'
      string = "Dodech. Science in the home. Nature 32:3"
      TitleAndCitationParser.parse(string).should == {
        :title => 'Dodech. Science in the home', 
        :citation => {
          :article => {
            :journal => 'Nature',
            :series_volume_issue => '32',
            :pagination => '3'}}}
    end

    it "should realize that a title can't end with a comma" do
      string = "Taxonomy, phylogeny: Philip Jr., 1904-1983. Series Entomologica (Dordrecht) 33:1-514."
      TitleAndCitationParser.parse(string).should == {
        :title => 'Taxonomy, phylogeny: Philip Jr., 1904-1983',
        :citation => {
          :article => {
            :journal => 'Series Entomologica (Dordrecht)',
            :series_volume_issue => '33',
            :pagination => '1-514'}}}
    end

    it "should be able to handle this weird journal name, as long as it exists" do
      Journal.create! :name => 'Verhandlungen der Kaiserlich-Königlichen Zoologisch-Botanischen Gesellschaft in Wien'
      string = "Ameisen aus Sao Paulo (Brasilien), Paraguay etc. gesammelt von Prof. Herm. v. Ihering, Dr. Lutz, Dr. Fiebrig, etc. Verhandlungen der Kaiserlich-Königlichen Zoologisch-Botanischen Gesellschaft in Wien 58:340-418"
      TitleAndCitationParser.parse(string).should == {
        :title => 'Ameisen aus Sao Paulo (Brasilien), Paraguay etc. gesammelt von Prof. Herm. v. Ihering, Dr. Lutz, Dr. Fiebrig, etc',
        :citation => {
          :article => {
            :journal => 'Verhandlungen der Kaiserlich-Königlichen Zoologisch-Botanischen Gesellschaft in Wien',
            :series_volume_issue => '58',
            :pagination => '340-418'}}}
    end

    it "should find the journal name in this one anyway, as it contains no periods" do
      string = "Ameisen aus Sao Paulo (Brasilien), Paraguay etc. gesammelt von Prof. Herm. v. Ihering, Dr. Lutz, Dr. Fiebrig, etc. Verhandlungen der Kaiserlich-Königlichen Zoologisch-Botanischen Gesellschaft in Wien 58:340-418"
      TitleAndCitationParser.parse(string).should == {
        :title => 'Ameisen aus Sao Paulo (Brasilien), Paraguay etc. gesammelt von Prof. Herm. v. Ihering, Dr. Lutz, Dr. Fiebrig, etc',
        :citation => {
          :article => {
            :journal => 'Verhandlungen der Kaiserlich-Königlichen Zoologisch-Botanischen Gesellschaft in Wien',
            :series_volume_issue => '58',
            :pagination => '340-418'}}}
    end

  end

  describe "titles that include bracketed expressions" do
    it "should include bracketed expressions in the title when the period is inside the brackets" do
      string = "[Untitled.] New York:Wiley, 23 pp."
      TitleAndCitationParser.parse(string).should == {
        :title => '[Untitled.]',
        :citation => {
          :book => {
            :publisher => {:name => 'Wiley', :place => 'New York'},
            :pagination => '23 pp.'}}}
    end

    it "should include bracketed expressions in the title when the period is outside the brackets" do
      string = "[Untitled]. New York:Wiley, 23 pp."
      TitleAndCitationParser.parse(string).should == {
        :title => '[Untitled]',
        :citation => {
          :book => {
            :publisher => {:name => 'Wiley', :place => 'New York'},
            :pagination => '23 pp.'}}}
    end
    
  end

  describe "unparseable strings" do
    it "should take the first sentence as the title and the rest as the citation" do
      TitleAndCitationParser.parse('Ants. A book').should == {:title => 'Ants', :citation => {:unknown => 'A book'}}
    end
  end

end
