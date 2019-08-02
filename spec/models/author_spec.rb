require 'spec_helper'

describe Author do
  it { is_expected.to be_versioned }

  describe 'relations' do
    it { is_expected.to have_many(:names).class_name('AuthorName').dependent(:destroy) }
    it { is_expected.to have_many(:references).dependent(:restrict_with_error) }
  end

  describe "scopes" do
    describe ".sorted_by_name" do
      let!(:ward) { create :author_name, name: 'Ward' }
      let!(:bolton) { create :author_name, name: 'Bolton' }
      let!(:fisher) { create :author_name, name: 'Fisher, B. L.' }

      it "sorts by first author name" do
        expect(described_class.sorted_by_name).to eq [bolton.author, fisher.author, ward.author]
      end
    end
  end

  describe "#merge" do
    let!(:target_author) { create(:author_name, name: 'Bolton, B').author }
    let!(:author_to_merge) { create(:author_name, name: 'Bolton,B.').author }

    it "makes all the names of the passed in authors belong to the same author" do
      expect(described_class.count).to eq 2
      expect(AuthorName.count).to eq 2

      all_names = (target_author.names + author_to_merge.names).uniq.sort

      target_author.merge author_to_merge
      expect(all_names.all? { |name| name.author == target_author }).to be true

      expect(described_class.count).to eq 1
      expect(AuthorName.count).to eq 2
    end
  end

  describe '#described_taxa' do
    let(:author) { create :author }
    let(:author_name) { create :author_name, author: author }
    let!(:species) do
      reference = create :article_reference, author_names: [author_name]
      species = create :species
      species.protonym.authorship.update!(reference: reference)
      species
    end
    let!(:genus) do
      reference = create :book_reference, author_names: [author_name]
      genus = create :genus
      genus.protonym.authorship.update!(reference: reference)
      genus
    end

    before { create :species } # Unrelated.

    it "returns taxa described by the author" do
      expect(author.described_taxa).to eq [species, genus]
    end
  end
end
