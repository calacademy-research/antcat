require 'spec_helper'

describe Parsers::AuthorParser do
  describe ".parse" do
    it "returns an empty array if the string is blank" do
      expect(described_class.parse('')).to eq []
      expect(described_class.parse(nil)).to eq []
    end

    it "parses a single author into a one-element array" do
      expect(described_class.parse('Fisher, B.L.')).to eq ['Fisher, B.L.']
    end

    it "parses multiple authors" do
      expect(described_class.parse('Fisher, B.L.; Wheeler, W.M.')).to eq ['Fisher, B.L.', 'Wheeler, W.M.']
    end

    it "handles names with hyphens" do
      expect(described_class.parse('Abdul-Rassoul, M.S.')).to eq ['Abdul-Rassoul, M.S.']
    end

    it "handles a name with two last names" do
      expect(described_class.parse('Baroni Urbani, C.')).to eq ['Baroni Urbani, C.']
    end

    it "handles a name with an apostrophe" do
      expect(described_class.parse("Passerin d'Entrèves, P.")).to eq ["Passerin d'Entrèves, P."]
    end

    it "handles a name with an initial without a period, as long as it's before a semicolon" do
      expect(described_class.parse("Sanetra, M; Ward, P.")).to eq ['Sanetra, M', 'Ward, P.']
    end

    it "handles generation numbers" do
      expect(described_class.parse("Coody, C. J.; Watkins, J. F., II")).to eq ["Coody, C. J.", "Watkins, J. F., II"]
    end

    it "handles St." do
      expect(described_class.parse("St. Romain, M. K.")).to eq ["St. Romain, M. K."]
    end

    it "handles a name with one letter in part of it (not an abbreviation)" do
      expect(described_class.parse("Suñer i Escriche, D.")).to eq ["Suñer i Escriche, D."]
    end

    it "handles hyphenated first names" do
      expect(described_class.parse("Kim, J-H.; Park, S.-J.; Kim, B.-J.")).to eq ["Kim, J-H.", "Park, S.-J.", "Kim, B.-J."]
    end

    it "handles 'da' at the end of a name" do
      expect(described_class.parse("Silva, R. R. da; Lopes, B. C.")).to eq ['Silva, R. R. da', 'Lopes, B. C.']
    end

    it "handles 'dos' in the middle of a name" do
      expect(described_class.parse("Feitosa, R. dos S. M.")).to eq ['Feitosa, R. dos S. M.']
    end

    it "handle 'da' at the beginning of a name" do
      expect(described_class.parse("da Silva, R. R.")).to eq ['da Silva, R. R.']
    end

    it "handles authors separated by commas" do
      expect(described_class.parse("Beed, M. D., Page, R., Ward, P.S.")).to eq ['Beed, M. D.', 'Page, R.', 'Ward, P.S.']
    end

    it "handles 'Jr.'" do
      expect(described_class.parse('Brown, W. L., Jr.; Kempf, W. W.')).to eq ['Brown, W. L., Jr.', 'Kempf, W. W.']
    end

    it "handles 'Sr.'" do
      expect(described_class.parse('Brown, W. L., Sr.')).to eq ['Brown, W. L., Sr.']
    end

    it "handles 'III'" do
      expect(described_class.parse('Morrison, W.R., III')).to eq ['Morrison, W.R., III']
    end

    it "handles 'Jr'" do
      expect(described_class.parse('Brown, W. L., Jr; Kempf, W. W.')).to eq ['Brown, W. L., Jr', 'Kempf, W. W.']
    end

    it "handles a phrase that's known to be an author" do
      expect(described_class.parse('Anonymous')).to eq ['Anonymous']
    end

    it "parses this weird one" do
      expect(described_class.parse('Arias P., T. M.')).to eq ['Arias P., T. M.']
    end

    it "handles a semicolon followed by a space at the end" do
      expect(described_class.parse('Ward, P. S.; ')).to eq ['Ward, P. S.']
    end

    it "handles an authors list separated by ampersand" do
      expect(described_class.parse('Espadaler & DuMerle')).to eq ['Espadaler', 'DuMerle']
    end
  end
end
