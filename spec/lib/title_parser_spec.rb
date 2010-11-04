require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TitleParser do
  it "should extract a simple title from book reference" do
    string = "Ants. Cambridge:Harvard 320 pp."
    TitleParser.parse(string).should == 'Ants'
    string.should == "Cambridge:Harvard 320 pp."
  end

  it "should extract a simple title from an article reference" do
    string = "Ants. Psyche 30:1"
    TitleParser.parse(string).should == 'Ants'
    string.should == "Psyche 30:1"
  end

  describe "nested references" do
    it "should extract a simple title followed by 'In:'" do
      string = "Ants. In: Ward, P.S. Ants. New York:Wiley 32 pp."
      TitleParser.parse(string).should == 'Ants'
      string.should == "In: Ward, P.S. Ants. New York:Wiley 32 pp."
    end
    it "should extract a simple title followed by a more complicated pages_in" do
      string = "Ants. Pp. 32, 4, 5 in Ward, P.S. Ants. New York:Wiley 32 pp."
      TitleParser.parse(string).should == 'Ants'
      string.should == "Pp. 32, 4, 5 in Ward, P.S. Ants. New York:Wiley 32 pp."
    end
    it "should extract a simple title followed by a double nested citation" do
      string = "Ants. Pp. 32, 4, 5 in Ward, P.S. Ants. In: Bolton, B. More ants. New York:Wiley 32 pp."
      TitleParser.parse(string).should == 'Ants'
      string.should == "Pp. 32, 4, 5 in Ward, P.S. Ants. In: Bolton, B. More ants. New York:Wiley 32 pp."
    end

    it "should not find 'in' in the middle of a title" do
      string = "Ants in Madagascar. New York:Wiley 32 pp."
      TitleParser.parse(string).should == 'Ants in Madagascar'
      string.should == "New York:Wiley 32 pp."
    end
  end

  describe "titles with periods in them" do
    it "should work when the following citation is nested" do
      string = "Ants of St. Croix. In: Ward, P.S. Ants. New York:Wiley 32 pp."
      TitleParser.parse(string).should == 'Ants of St. Croix'
      string.should == "In: Ward, P.S. Ants. New York:Wiley 32 pp."
    end

    ['Abhandlungen', 'Acta', 'Actes', 'Anales', 'Annalen', 'Annales', 'Annali', 'Annals', 'Archives', 'Archivos', 'Arquivos',
     'Boletim', 'Boletin', 'Bollettino', 'Bulletin', 'Izvestiya', 'Journal', 'Memoires', 'Memoirs', 'Memorias', 'Memorie',
     'Mitteilungen', 'Occasional Papers'].each do |word|
      it "should find the title when the journal name starts with '#{word}'" do
        string = "Dodech. Ants. #{word} 32:3"
        TitleParser.parse(string).should == 'Dodech. Ants'
        string.should == "#{word} 32:3"
      end
     end

    it "should find the title when the journal name is already known" do
      Journal.create! :title => 'Science'
      string = "Dodech. Ants. Science 32:3"
      TitleParser.parse(string).should == 'Dodech. Ants'
      string.should == "Science 32:3"
    end

    it "should find the title when the place name is already known" do
      Publisher.create! :name => 'Wiley', :place => 'Las Vegas'
      string = "Dodech. Ants. Las Vegas:Barnes 32 pp."
      TitleParser.parse(string).should == 'Dodech. Ants'
      string.should == "Las Vegas:Barnes 32 pp."
    end

    it "should not be fooled by a string that merely starts with the name of a journal" do
      Journal.create! :title => 'Science'
      string = "Dodech. Science in the home. Nature 32:3"
      TitleParser.parse(string).should == 'Dodech'
    end

    it "should realize that a title can't end with a comma" do
      string = "Taxonomy, phylogeny: Philip Jr., 1904-1983. Series Entomologica (Dordrecht) 33:1-514."
      TitleParser.parse(string).should == 'Taxonomy, phylogeny: Philip Jr., 1904-1983'
    end

  end

end
