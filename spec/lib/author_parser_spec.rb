require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AuthorParser do

  describe "parsing author names" do
    it "should return an empty array if the string is empty" do
      ['', nil].each do |string|
        AuthorParser.get_author_names(string).should == []
      end
    end

    it "should parse a single author into a one-element array" do
      string = 'Fisher, B.L.'
      AuthorParser.get_author_names(string).should == ['Fisher, B.L.']
      string.should == ''
    end

    it "should parse multiple authors" do
      string = 'Fisher, B.L.; Wheeler, W.M.'
      AuthorParser.get_author_names(string).should == ['Fisher, B.L.', 'Wheeler, W.M.']
      string.should == ''
    end

    it "should stop when it runs out of names" do
      string = 'Fisher, B.L.; Wheeler, W.M. Ants.'
      AuthorParser.get_author_names(string).should == ['Fisher, B.L.', 'Wheeler, W.M.']
      string.should == 'Ants.'
    end

    it "should handle names with hyphens" do
      AuthorParser.get_author_names('Abdul-Rassoul, M.S.').should == ['Abdul-Rassoul, M.S.']
    end

    it "should handle a name with two last names" do
      AuthorParser.get_author_names('Baroni Urbani, C.').should == ['Baroni Urbani, C.']
    end

    it "should handle a name with an apostrophe" do
      AuthorParser.get_author_names("Passerin d'Entrèves, P.").should == ["Passerin d'Entrèves, P."]
    end

    it "should handle a name with one letter in part of it (not an abbreviation)" do
      AuthorParser.get_author_names("Suñer i Escriche, D.").should == ["Suñer i Escriche, D."]
    end

    it "should handle hyphenated first names" do
      AuthorParser.get_author_names("Kim, J-H.; Park, S.-J.; Kim, B.-J.").should == ["Kim, J-H.", "Park, S.-J.", "Kim, B.-J."]
    end

    it "should handle 'da' at the end of a name" do
      AuthorParser.get_author_names("Silva, R. R. da; Lopes, B. C.").should == ['Silva, R. R. da', 'Lopes, B. C.']
    end

    it "should handle 'da' at the beginning of a name" do
      AuthorParser.get_author_names("da Silva, R. R.").should == ['da Silva, R. R.']
    end

    it "should handle roles" do
      AuthorParser.get_author_names("Breed, M. D.; Page, R. E. (eds.)").should == ['Breed, M. D.', 'Page, R. E. (eds.)']
    end

    it "should handle authors separated by commas" do
      AuthorParser.get_author_names("Breed, M. D., Page, R. E., Ward, P.S.").should == ['Breed, M. D.', 'Page, R. E.', 'Ward, P.S.']
    end
    
    it "should handle no author at all" do
      AuthorParser.get_author_names("This is actually the title.").should == []
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
