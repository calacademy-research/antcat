require 'spec_helper'

describe Ward::AuthorParser do

  describe "parsing author names" do
    it "should return an empty array if the string is empty" do
      ['', nil].each do |string|
        Ward::AuthorParser.parse(string)[:names].should == []
      end
    end

    it "should parse a single author into a one-element array" do
      string = 'Fisher, B.L.'
      Ward::AuthorParser.parse(string)[:names].should == ['Fisher, B.L.']
      string.should == ''
    end

    it "should parse a single author + author roles into a hash" do
      string = 'Fisher, B.L. (ed.)'
      Ward::AuthorParser.parse(string).should == {:names => ['Fisher, B.L.'], :suffix => ' (ed.)'}
      string.should == ''
    end

    it "should parse multiple authors" do
      string = 'Fisher, B.L.; Wheeler, W.M.'
      Ward::AuthorParser.parse(string)[:names].should == ['Fisher, B.L.', 'Wheeler, W.M.']
      string.should == ''
    end

    it "should multiple authors with a role" do
      Ward::AuthorParser.parse("Breed, M. D.; Page, R. E. (eds.)").should ==
        {:names => ['Breed, M. D.', 'Page, R. E.'], :suffix => ' (eds.)'}
    end

    it "should stop when it runs out of names" do
      string = 'Fisher, B.L.; Wheeler, W.M. Ants.'
      Ward::AuthorParser.parse(string)[:names].should == ['Fisher, B.L.', 'Wheeler, W.M.']
      string.should == 'Ants.'
    end

    it "should handle names with hyphens" do
      Ward::AuthorParser.parse('Abdul-Rassoul, M.S.')[:names].should == ['Abdul-Rassoul, M.S.']
    end

    it "should handle a name with two last names" do
      Ward::AuthorParser.parse('Baroni Urbani, C.')[:names].should == ['Baroni Urbani, C.']
    end

    it "should handle a name with an apostrophe" do
      Ward::AuthorParser.parse("Passerin d'Entrèves, P.")[:names].should == ["Passerin d'Entrèves, P."]
    end

    it "should handle a name with an initial without a period, as long as it's before a semicolon" do
      Ward::AuthorParser.parse("Sanetra, M; Ward, P.")[:names].should == ['Sanetra, M', 'Ward, P.']
    end

    it "should handle 'et al.' without a comma before it" do
      Ward::AuthorParser.parse("Sanetra, M; Ward, P. et al.").should == {:names => ['Sanetra, M', 'Ward, P.'], :suffix => ' et al.'}
    end

    it "should handle 'et al.' with a comma before it" do
      Ward::AuthorParser.parse("Sanetra, M; Ward, P., et al.").should == {:names => ['Sanetra, M', 'Ward, P.'], :suffix => ', et al.'}
    end

    it "should handle 'et al. (eds.)'" do
      Ward::AuthorParser.parse("Sanetra, M; Ward, P., et al. (eds.)").should == {:names => ['Sanetra, M', 'Ward, P.'], :suffix => ', et al. (eds.)'}
    end

    it "should strip the space after the suffix" do
      string = "Sanetra, M; Ward, P., et al. (eds.) Ants"
      Ward::AuthorParser.parse(string)
      string.should == 'Ants'
    end

    it "should handle generation numbers" do
      Ward::AuthorParser.parse("Coody, C. J.; Watkins, J. F., II")[:names].should == ["Coody, C. J.", "Watkins, J. F., II"]
    end

    it "should handle St." do
      Ward::AuthorParser.parse("St. Romain, M. K.")[:names].should == ["St. Romain, M. K."]
    end

    it "should handle a name with one letter in part of it (not an abbreviation)" do
      Ward::AuthorParser.parse("Suñer i Escriche, D.")[:names].should == ["Suñer i Escriche, D."]
    end

    it "should handle hyphenated first names" do
      Ward::AuthorParser.parse("Kim, J-H.; Park, S.-J.; Kim, B.-J.")[:names].should == ["Kim, J-H.", "Park, S.-J.", "Kim, B.-J."]
    end

    it "should handle 'da' at the end of a name" do
      Ward::AuthorParser.parse("Silva, R. R. da; Lopes, B. C.")[:names].should == ['Silva, R. R. da', 'Lopes, B. C.']
    end

    it "should handle 'dos' in the middle of a name" do
      Ward::AuthorParser.parse("Feitosa, R. dos S. M.")[:names].should == ['Feitosa, R. dos S. M.']
    end

    it "should handle 'da' at the beginning of a name" do
      Ward::AuthorParser.parse("da Silva, R. R.")[:names].should == ['da Silva, R. R.']
    end

    it "should handle authors separated by commas" do
      Ward::AuthorParser.parse("Breed, M. D., Page, R. E., Ward, P.S.")[:names].should == ['Breed, M. D.', 'Page, R. E.', 'Ward, P.S.']
    end
    
    it "should handle no author at all" do
      Ward::AuthorParser.parse("This is actually the title.")[:names].should == []
    end
    
    it "should handle 'Jr.'" do
      string = 'Brown, W. L., Jr.; Kempf, W. W.'
      Ward::AuthorParser.parse(string)[:names].should == ['Brown, W. L., Jr.', 'Kempf, W. W.']
      string.should == ''
    end

    it "should handle 'Jr'" do
      string = 'Brown, W. L., Jr; Kempf, W. W.'
      Ward::AuthorParser.parse(string)[:names].should == ['Brown, W. L., Jr', 'Kempf, W. W.']
      string.should == ''
    end

    it "should handle a phrase that's known to be an author" do
      Factory :author_name, :name => 'Anonymous', :verified => true
      string = 'Anonymous'
      Ward::AuthorParser.parse(string)[:names].should == ['Anonymous']
      string.should be_empty
    end

    it "should be able to parse this weird one" do
      Ward::AuthorParser.parse('Arias P., T. M.')[:names].should == ['Arias P., T. M.']
    end

    it "should keep the 'author suffix' part of the title when there is no author" do
      string = 'Report on the recorded animal life of Moscow province (No. 4). [In Russian.]'
      Ward::AuthorParser.parse(string).should == {:names => [], :suffix => nil}
    end
  end

end
