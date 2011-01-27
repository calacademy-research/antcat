require 'spec_helper'

describe AuthorParser do
  describe "parsing author names" do
    it "should return an empty array if the string is empty" do
      ['', nil].each do |string|
        AuthorParser.parse(string)[:names].should == []
      end
    end

    it "should parse a single author into a one-element array" do
      string = 'Fisher, B.L.'
      AuthorParser.parse(string)[:names].should == ['Fisher, B.L.']
      string.should == ''
    end

   it "should parse a single author + author roles into a hash" do
     string = 'Fisher, B.L. (ed.)'
     AuthorParser.parse(string).should == {:names => ['Fisher, B.L.'], :suffix => ' (ed.)'}
     string.should == ''
   end

   it "should parse multiple authors" do
     string = 'Fisher, B.L.; Wheeler, W.M.'
     AuthorParser.parse(string)[:names].should == ['Fisher, B.L.', 'Wheeler, W.M.']
     string.should == ''
   end

   it "should multiple authors with a role" do
     AuthorParser.parse("Breed, M. D.; Page, R. E. (eds.)").should ==
       {:names => ['Breed, M. D.', 'Page, R. E.'], :suffix => ' (eds.)'}
   end

   it "should handle names with hyphens" do
     AuthorParser.parse('Abdul-Rassoul, M.S.')[:names].should == ['Abdul-Rassoul, M.S.']
   end

   it "should handle a name with two last names" do
     AuthorParser.parse('Baroni Urbani, C.')[:names].should == ['Baroni Urbani, C.']
   end

   it "should handle a name with an apostrophe" do
     AuthorParser.parse("Passerin d'Entrèves, P.")[:names].should == ["Passerin d'Entrèves, P."]
   end

   it "should handle a name with an initial without a period, as long as it's before a semicolon" do
     AuthorParser.parse("Sanetra, M; Ward, P.")[:names].should == ['Sanetra, M', 'Ward, P.']
   end

   it "should handle 'et al.' without a comma before it" do
     AuthorParser.parse("Sanetra, M; Ward, P. et al.").should == {:names => ['Sanetra, M', 'Ward, P.'], :suffix => ' et al.'}
   end

   it "should handle 'et al.' with a comma before it" do
     AuthorParser.parse("Sanetra, M; Ward, P., et al.").should == {:names => ['Sanetra, M', 'Ward, P.'], :suffix => ', et al.'}
   end

   it "should handle 'et al. (eds.)'" do
     AuthorParser.parse("Sanetra, M; Ward, P., et al. (eds.)").should == {:names => ['Sanetra, M', 'Ward, P.'], :suffix => ', et al. (eds.)'}
   end

   it "should strip the space after the suffix" do
     string = "Sanetra, M; Ward, P., et al. (eds.) Ants"
     AuthorParser.parse(string)
     string.should == 'Ants'
   end

   it "should handle generation numbers" do
     AuthorParser.parse("Coody, C. J.; Watkins, J. F., II")[:names].should == ["Coody, C. J.", "Watkins, J. F., II"]
   end

   it "should handle St." do
     AuthorParser.parse("St. Romain, M. K.")[:names].should == ["St. Romain, M. K."]
   end

   it "should handle a name with one letter in part of it (not an abbreviation)" do
     AuthorParser.parse("Suñer i Escriche, D.")[:names].should == ["Suñer i Escriche, D."]
   end

   it "should handle hyphenated first names" do
     AuthorParser.parse("Kim, J-H.; Park, S.-J.; Kim, B.-J.")[:names].should == ["Kim, J-H.", "Park, S.-J.", "Kim, B.-J."]
   end

   it "should handle 'da' at the end of a name" do
     AuthorParser.parse("Silva, R. R. da; Lopes, B. C.")[:names].should == ['Silva, R. R. da', 'Lopes, B. C.']
   end

   it "should handle 'dos' in the middle of a name" do
     AuthorParser.parse("Feitosa, R. dos S. M.")[:names].should == ['Feitosa, R. dos S. M.']
   end

   it "should handle 'da' at the beginning of a name" do
     AuthorParser.parse("da Silva, R. R.")[:names].should == ['da Silva, R. R.']
   end

   it "should handle authors separated by commas" do
     AuthorParser.parse("Breed, M. D., Page, R. E., Ward, P.S.")[:names].should == ['Breed, M. D.', 'Page, R. E.', 'Ward, P.S.']
   end
    
   it "should handle 'Jr.'" do
     string = 'Brown, W. L., Jr.; Kempf, W. W.'
     AuthorParser.parse(string)[:names].should == ['Brown, W. L., Jr.', 'Kempf, W. W.']
     string.should == ''
   end

   it "should handle 'Jr'" do
     string = 'Brown, W. L., Jr; Kempf, W. W.'
     AuthorParser.parse(string)[:names].should == ['Brown, W. L., Jr', 'Kempf, W. W.']
     string.should == ''
   end

   it "should handle a phrase that's known to be an author" do
     Factory :author_name, :name => 'Anonymous', :verified => true
     string = 'Anonymous'
     AuthorParser.parse(string)[:names].should == ['Anonymous']
     string.should be_empty
   end

   it "should be able to parse this weird one" do
     AuthorParser.parse('Arias P., T. M.')[:names].should == ['Arias P., T. M.']
   end

   it "should handle a semicolon followed by a space at the end" do
     AuthorParser.parse('Ward, P. S.; ').should == {:names => ['Ward, P. S.'], :suffix => nil}
   end

   it "should handle an authors list separated by ampersand" do
     AuthorParser.parse('Espadaler & DuMerle').should == {:names => ['Espadaler', 'DuMerle'], :suffix => nil}
   end

  end

  describe "parsing first name and initials and last name" do
   it "should return an empty hash if the string is empty" do
     ['', nil].each do |string|
       AuthorParser.get_name_parts(string).should == {}
     end
   end
   it "should simply return the name if there's only one word" do
     AuthorParser.get_name_parts('Bolton').should == {:last => 'Bolton'}
   end
   it "should separate the words if there are multiple" do
     AuthorParser.get_name_parts('Bolton, B.L.').should == {:last => 'Bolton', :first_and_initials => 'B.L.'}
   end
   it "should use all words if there is no comma" do
     AuthorParser.get_name_parts('Royal Academy').should == {:last => 'Royal Academy'}
   end
   it "should use use all words before the comma if there are multiple" do
     AuthorParser.get_name_parts('Baroni Urbani, C.').should == {:last => 'Baroni Urbani', :first_and_initials => 'C.'}
   end
  end

end
