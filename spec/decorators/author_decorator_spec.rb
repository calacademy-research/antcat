require "spec_helper"

describe AuthorDecorator do
  let(:author) { create :author }
  let(:author_name) { create :author_name, author: author }
  let!(:reference) do
    create :article_reference, author_names: [author_name], citation_year: 2000
  end

  describe "#published_between" do
    context "when start and end year are the same" do
      specify { expect(author.decorate.published_between).to eq reference.year }
    end

    context "when start and end year are not the same" do
      before do
        create :article_reference, author_names: [author_name], citation_year: 2010
      end

      specify { expect(author.decorate.published_between).to eq "2000&ndash;2010" }
    end
  end

  describe "#taxon_descriptions_between" do
    before { create_species.protonym.authorship.update! reference: reference }

    context "when start and end year are the same" do
      specify do
        expect(author.decorate.taxon_descriptions_between).to eq reference.year
      end
    end

    context "when start and end year are not the same" do
      before do
        second_reference = create :article_reference, author_names: [author_name], citation_year: 2010
        create_genus.protonym.authorship.update! reference: second_reference
      end

      specify do
        expect(author.decorate.taxon_descriptions_between).to eq "2000&ndash;2010"
      end
    end
  end
end
