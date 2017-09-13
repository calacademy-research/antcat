require "spec_helper"

describe Authors::DescribedTaxa do
  let(:author) { create :author }
  let(:author_name) { create :author_name, author: author }
  let!(:species) do
    reference = create :article_reference, author_names: [author_name]
    species = create_species
    species.protonym.authorship.update! reference: reference
    species
  end
  let!(:genus) do
    reference = create :book_reference, author_names: [author_name]
    genus = create_genus
    genus.protonym.authorship.update! reference: reference
    genus
  end

  before { create_species } # Unrelated.

  describe "#call" do
    it "returns taxa described by the author" do
      expect(described_class[author]).to eq [species, genus]
    end
  end
end
