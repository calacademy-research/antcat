require 'spec_helper'

describe Parsers::AuthorParser do
  before do
    @parser = Parsers::AuthorParser
  end

  describe "parsing author names" do
    describe "Modifying the input string" do
      it "should modify the string if the bang version is used" do
        string = 'Fisher, B.L.'
        expect(@parser.parse!(string)[:names]).to eq(['Fisher, B.L.'])
        expect(string).to eq('')
      end
      it "should not modify the string if the bang version is not used" do
        string = 'Fisher, B.L.'
        expect(@parser.parse(string)[:names]).to eq(['Fisher, B.L.'])
        expect(string).to eq('Fisher, B.L.')
      end
    end
    it "should return an empty array if the string is empty" do
      ['', nil].each do |string|
        expect(@parser.parse(string)[:names]).to eq([])
      end
    end

    it "should parse a single author into a one-element array" do
      string = 'Fisher, B.L.'
      expect(@parser.parse!(string)[:names]).to eq(['Fisher, B.L.'])
      expect(string).to eq('')
    end

   it "should parse a single author + author roles into a hash" do
     string = 'Fisher, B.L. (ed.)'
     result = @parser.parse! string
     expect(result).to eq(names: ['Fisher, B.L.'], suffix: ' (ed.)')
     expect(result[:suffix].class).to eq(String)
     expect(string).to eq('')
   end

   it "should parse multiple authors" do
     string = 'Fisher, B.L.; Wheeler, W.M.'
     expect(@parser.parse!(string)[:names]).to eq(['Fisher, B.L.', 'Wheeler, W.M.'])
     expect(string).to eq('')
   end

   it "should multiple authors with a role" do
     expect(@parser.parse("Breed, M. D.; Page, R. E. (eds.)")).to eq(
       names: ['Breed, M. D.', 'Page, R. E.'], suffix: ' (eds.)'
     )
   end

   it "should handle names with hyphens" do
     expect(@parser.parse('Abdul-Rassoul, M.S.')[:names]).to eq(['Abdul-Rassoul, M.S.'])
   end

   it "should handle a name with two last names" do
     expect(@parser.parse('Baroni Urbani, C.')[:names]).to eq(['Baroni Urbani, C.'])
   end

   it "should handle a name with an apostrophe" do
     expect(@parser.parse("Passerin d'Entrèves, P.")[:names]).to eq(["Passerin d'Entrèves, P."])
   end

   it "should handle a name with an initial without a period, as long as it's before a semicolon" do
     expect(@parser.parse("Sanetra, M; Ward, P.")[:names]).to eq(['Sanetra, M', 'Ward, P.'])
   end

   it "should handle 'et al.' without a comma before it" do
     expect(@parser.parse("Sanetra, M; Ward, P. et al.")).to eq(names: ['Sanetra, M', 'Ward, P.'], suffix: ' et al.')
   end

   it "should handle 'et al.' with a comma before it" do
     expect(@parser.parse("Sanetra, M; Ward, P., et al.")).to eq(names: ['Sanetra, M', 'Ward, P.'], suffix: ', et al.')
   end

   it "should handle 'et al. (eds.)'" do
     expect(@parser.parse("Sanetra, M; Ward, P., et al. (eds.)")).to eq(names: ['Sanetra, M', 'Ward, P.'], suffix: ', et al. (eds.)')
   end

   it "should strip the space after the suffix" do
     string = "Sanetra, M; Ward, P., et al. (eds.) Ants"
     @parser.parse!(string)
     expect(string).to eq('Ants')
   end

   it "should handle generation numbers" do
     expect(@parser.parse("Coody, C. J.; Watkins, J. F., II")[:names]).to eq(["Coody, C. J.", "Watkins, J. F., II"])
   end

   it "should handle St." do
     expect(@parser.parse("St. Romain, M. K.")[:names]).to eq(["St. Romain, M. K."])
   end

   it "should handle a name with one letter in part of it (not an abbreviation)" do
     expect(@parser.parse("Suñer i Escriche, D.")[:names]).to eq(["Suñer i Escriche, D."])
   end

   it "should handle hyphenated first names" do
     expect(@parser.parse("Kim, J-H.; Park, S.-J.; Kim, B.-J.")[:names]).to eq(["Kim, J-H.", "Park, S.-J.", "Kim, B.-J."])
   end

   it "should handle 'da' at the end of a name" do
     expect(@parser.parse("Silva, R. R. da; Lopes, B. C.")[:names]).to eq(['Silva, R. R. da', 'Lopes, B. C.'])
   end

   it "should handle 'dos' in the middle of a name" do
     expect(@parser.parse("Feitosa, R. dos S. M.")[:names]).to eq(['Feitosa, R. dos S. M.'])
   end

   it "should handle 'da' at the beginning of a name" do
     expect(@parser.parse("da Silva, R. R.")[:names]).to eq(['da Silva, R. R.'])
   end

   it "should handle authors separated by commas" do
     expect(@parser.parse("Breed, M. D., Page, R. E., Ward, P.S.")[:names]).to eq(['Breed, M. D.', 'Page, R. E.', 'Ward, P.S.'])
   end

   it "should handle 'Jr.'" do
     string = 'Brown, W. L., Jr.; Kempf, W. W.'
     expect(@parser.parse!(string)[:names]).to eq(['Brown, W. L., Jr.', 'Kempf, W. W.'])
     expect(string).to eq('')
   end

   it "should handle 'Sr.'" do
     string = 'Brown, W. L., Sr.'
     expect(@parser.parse!(string)[:names]).to eq(['Brown, W. L., Sr.'])
     expect(string).to eq('')
   end

   it "should handle 'III'" do
     string = 'Morrison, W.R., III'
     expect(@parser.parse!(string)[:names]).to eq(['Morrison, W.R., III'])
     expect(string).to eq('')
   end

   it "should handle 'Jr'" do
     string = 'Brown, W. L., Jr; Kempf, W. W.'
     expect(@parser.parse!(string)[:names]).to eq(['Brown, W. L., Jr', 'Kempf, W. W.'])
     expect(string).to eq('')
   end

   it "should handle a phrase that's known to be an author" do
     create :author_name, name: 'Anonymous', verified: true
     string = 'Anonymous'
     expect(@parser.parse!(string)[:names]).to eq(['Anonymous'])
     expect(string).to be_empty
   end

   it "should be able to parse this weird one" do
     expect(@parser.parse('Arias P., T. M.')[:names]).to eq(['Arias P., T. M.'])
   end

   it "should handle a semicolon followed by a space at the end" do
     expect(@parser.parse('Ward, P. S.; ')).to eq(names: ['Ward, P. S.'], suffix: nil)
   end

   it "should handle an authors list separated by ampersand" do
     expect(@parser.parse('Espadaler & DuMerle')).to eq(names: ['Espadaler', 'DuMerle'], suffix: nil)
   end

  end

  describe "parsing first name and initials and last name" do
    it "should return an empty hash if the string is empty" do
      ['', nil].each do |string|
        expect(@parser.get_name_parts(string)).to eq({})
      end
    end
   it "should simply return the name if there's only one word" do
     expect(@parser.get_name_parts('Bolton')).to eq(last: 'Bolton')
   end
   it "should separate the words if there are multiple" do
     expect(@parser.get_name_parts('Bolton, B.L.')).to eq(last: 'Bolton', first_and_initials: 'B.L.')
   end
   it "should use all words if there is no comma" do
     expect(@parser.get_name_parts('Royal Academy')).to eq(last: 'Royal Academy')
   end
   it "should use use all words before the comma if there are multiple" do
     expect(@parser.get_name_parts('Baroni Urbani, C.')).to eq(last: 'Baroni Urbani', first_and_initials: 'C.')
   end
  end

end
