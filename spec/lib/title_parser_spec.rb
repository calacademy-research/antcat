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
  end

  describe "titles with periods in them" do
    it "work when the following citation is nested" do
      string = "Ants of St. Croix. In: Ward, P.S. Ants. New York:Wiley 32 pp."
      TitleParser.parse(string).should == 'Ants of St. Croix'
      string.should == "In: Ward, P.S. Ants. New York:Wiley 32 pp."
    end
  end

end
