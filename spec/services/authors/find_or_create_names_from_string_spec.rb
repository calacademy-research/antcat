require "spec_helper"

describe Authors::FindOrCreateNamesFromString do
  describe "#call" do
    it "finds or creates authors with names in the string" do
      AuthorName.create! name: 'Bolton, B.', author: Author.create!
      author_data = described_class['Ward, P.S.; Bolton, B.']
      expect(author_data.first.name).to eq 'Ward, P.S.'
      expect(author_data.second.name).to eq 'Bolton, B.'
      expect(AuthorName.count).to eq 2
    end

    it "returns the authors suffix" do
      author_data = described_class['Ward, P.S.; Bolton, B. (eds.)']
      expect(author_data.first.name).to eq 'Ward, P.S.'
      expect(author_data.second.name).to eq 'Bolton, B.'
    end

    it "handles 'the Andres'" do
      author_data = described_class['Andre, Edm.; Andre, Ern.']
      expect(author_data.first.name).to eq 'Andre, Edm.'
      expect(author_data.second.name).to eq 'Andre, Ern.'
    end

    it "handles invalid input" do
      author_data = described_class[' ; ']
      expect(author_data).to eq []
    end

    it "handles a semicolon followed by a space at the end" do
      author_data = described_class['Ward, P. S.; ']
      expect(author_data.size).to eq 1
      expect(author_data.first.name).to eq 'Ward, P. S.'
    end
  end
end
