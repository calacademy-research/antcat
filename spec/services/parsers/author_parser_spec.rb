require 'spec_helper'

describe Parsers::AuthorParser do
  subject(:parser) { described_class }

  describe "parsing author names" do
    describe "Modifying the input string" do
      it "modifies the string if the bang version is used" do
        string = 'Fisher, B.L.'
        expect(parser.parse!(string)).to eq ['Fisher, B.L.']
        expect(string).to eq ''
      end

      it "doesn't modify the string if the bang version is not used" do
        string = 'Fisher, B.L.'
        expect(parser.parse(string)).to eq ['Fisher, B.L.']
        expect(string).to eq 'Fisher, B.L.'
      end
    end

    it "returns an empty array if the string is empty" do
      expect(parser.parse('')).to eq []
      expect(parser.parse(nil)).to eq []
    end

    it "parses a single author into a one-element array" do
      string = 'Fisher, B.L.'
      expect(parser.parse!(string)).to eq ['Fisher, B.L.']
      expect(string).to eq ''
    end

    it "parses multiple authors" do
      string = 'Fisher, B.L.; Wheeler, W.M.'
      expect(parser.parse!(string)).to eq ['Fisher, B.L.', 'Wheeler, W.M.']
      expect(string).to eq ''
    end

    it "handles names with hyphens" do
      expect(parser.parse('Abdul-Rassoul, M.S.')).to eq ['Abdul-Rassoul, M.S.']
    end

    it "handles a name with two last names" do
      expect(parser.parse('Baroni Urbani, C.')).to eq ['Baroni Urbani, C.']
    end

    it "handles a name with an apostrophe" do
      expect(parser.parse("Passerin d'Entrèves, P.")).to eq ["Passerin d'Entrèves, P."]
    end

    it "handles a name with an initial without a period, as long as it's before a semicolon" do
      expect(parser.parse("Sanetra, M; Ward, P.")).to eq ['Sanetra, M', 'Ward, P.']
    end

    it "handles generation numbers" do
      expect(parser.parse("Coody, C. J.; Watkins, J. F., II")).
        to eq ["Coody, C. J.", "Watkins, J. F., II"]
    end

    it "handles St." do
      expect(parser.parse("St. Romain, M. K.")).to eq ["St. Romain, M. K."]
    end

    it "handles a name with one letter in part of it (not an abbreviation)" do
      expect(parser.parse("Suñer i Escriche, D.")).to eq ["Suñer i Escriche, D."]
    end

    it "handles hyphenated first names" do
      expect(parser.parse("Kim, J-H.; Park, S.-J.; Kim, B.-J.")).
        to eq ["Kim, J-H.", "Park, S.-J.", "Kim, B.-J."]
    end

    it "handles 'da' at the end of a name" do
      expect(parser.parse("Silva, R. R. da; Lopes, B. C.")).
        to eq ['Silva, R. R. da', 'Lopes, B. C.']
    end

    it "handles 'dos' in the middle of a name" do
      expect(parser.parse("Feitosa, R. dos S. M.")).to eq ['Feitosa, R. dos S. M.']
    end

    it "handle 'da' at the beginning of a name" do
      expect(parser.parse("da Silva, R. R.")).to eq ['da Silva, R. R.']
    end

    it "handles authors separated by commas" do
      expect(parser.parse("Breed, M. D., Page, R. E., Ward, P.S.")).
        to eq ['Breed, M. D.', 'Page, R. E.', 'Ward, P.S.']
    end

    it "handles 'Jr.'" do
      string = 'Brown, W. L., Jr.; Kempf, W. W.'
      expect(parser.parse!(string)).to eq ['Brown, W. L., Jr.', 'Kempf, W. W.']
      expect(string).to eq ''
    end

    it "handles 'Sr.'" do
      string = 'Brown, W. L., Sr.'
      expect(parser.parse!(string)).to eq ['Brown, W. L., Sr.']
      expect(string).to eq ''
    end

    it "handles 'III'" do
      string = 'Morrison, W.R., III'
      expect(parser.parse!(string)).to eq ['Morrison, W.R., III']
      expect(string).to eq ''
    end

    it "handles 'Jr'" do
      string = 'Brown, W. L., Jr; Kempf, W. W.'
      expect(parser.parse!(string)).to eq ['Brown, W. L., Jr', 'Kempf, W. W.']
      expect(string).to eq ''
    end

    it "handles a phrase that's known to be an author" do
      create :author_name, name: 'Anonymous'
      string = 'Anonymous'
      expect(parser.parse!(string)).to eq ['Anonymous']
      expect(string).to be_empty
    end

    it "parses this weird one" do
      expect(parser.parse('Arias P., T. M.')).to eq ['Arias P., T. M.']
    end

    it "handles a semicolon followed by a space at the end" do
      expect(parser.parse('Ward, P. S.; ')).to eq ['Ward, P. S.']
    end

    it "handles an authors list separated by ampersand" do
      expect(parser.parse('Espadaler & DuMerle')).to eq ['Espadaler', 'DuMerle']
    end
  end

  describe "parsing first name and initials and last name" do
    it "returns an empty hash if the string is empty" do
      expect(parser.get_name_parts('')).to eq({})
      expect(parser.get_name_parts(nil)).to eq({})
    end

    it "simply returns the name if there's only one word" do
      expect(parser.get_name_parts('Bolton')).to eq last: 'Bolton'
    end

    it "separates the words if there are multiple" do
      expect(parser.get_name_parts('Bolton, B.L.')).
       to eq last: 'Bolton', first_and_initials: 'B.L.'
    end

    it "uses all words if there is no comma" do
      expect(parser.get_name_parts('Royal Academy')).to eq last: 'Royal Academy'
    end

    it "uses all words before the comma if there are multiple" do
      expect(parser.get_name_parts('Baroni Urbani, C.')).
        to eq last: 'Baroni Urbani', first_and_initials: 'C.'
    end
  end
end
