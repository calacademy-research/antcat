require 'spec_helper'

describe Author do
  it { is_expected.to be_versioned }

  describe "scopes" do
    describe ".sorted_by_name" do
      let!(:ward) { create :author_name, name: 'Ward' }
      let!(:bolton) { create :author_name, name: 'Bolton' }
      let!(:fisher) do
        fisher_b_l = create :author_name, name: 'Fisher, B. L.'
        create :author_name, name: 'Fisher', author: fisher_b_l.author
      end

      it "sorts by first author name" do
        expect(described_class.sorted_by_name).to eq [bolton.author, fisher.author, ward.author]
      end
    end
  end

  describe ".find_by_names" do
    let!(:bolton) { create :author_name, name: 'Bolton' }
    let!(:fisher) { create :author_name, name: 'Fisher' }

    it "returns `Author`s" do
      expect(described_class.find_by_names(['Bolton', 'Fisher'])).
        to match_array [bolton.author, fisher.author]
    end

    it "handles empty lists" do
      expect(described_class.find_by_names([])).to eq []
    end
  end

  describe ".merge" do
    let!(:first_bolton_author) { create(:author_name, name: 'Bolton, B').author }
    let!(:second_bolton_author) { create(:author_name, name: 'Bolton,B.').author }

    it "makes all the names of the passed in authors belong to the same author" do
      expect(described_class.count).to eq 2
      expect(AuthorName.count).to eq 2

      all_names = (first_bolton_author.names + second_bolton_author.names).uniq.sort

      described_class.merge [first_bolton_author, second_bolton_author]
      expect(all_names.all? { |name| name.author == first_bolton_author }).to be true

      expect(described_class.count).to eq 1
      expect(AuthorName.count).to eq 2
    end
  end
end
