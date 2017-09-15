# TODO cleanup spec.

require 'spec_helper'

describe Reference do
  # Throw in a MissingReference to make sure it's not returned.
  before { create :missing_reference }

  describe ".perform_search" do
    describe "Search parameters" do
      describe "Authors", search: true do
        it "finds the references for all aliases of a given author_name", pending: true do
          pending "broke when search method was refactored"
          # TODO find out where this is used
          bolton = create :author
          bolton_barry = create :author_name, author: bolton, name: 'Bolton, Barry'
          bolton_b = create :author_name, author: bolton, name: 'Bolton, B.'
          bolton_barry_reference = create :book_reference, author_names: [bolton_barry], title: '1', pagination: '1'
          bolton_b_reference = create :book_reference, author_names: [bolton_b], title: '2', pagination: '2'

          expect(described_class.perform_search(authors: [bolton]).map(&:id)).to match(
            [bolton_b_reference, bolton_barry_reference].map(&:id)
          )
        end
      end
    end
  end

  describe ".solr_search", search: true do
    it "returns an empty array if nothing is found for author_name" do
      create :reference
      Sunspot.commit

      expect(described_class.solr_search { keywords 'foo' }.results).to be_empty
    end

    it "finds the reference for a given author_name if it exists" do
      reference = reference_factory author_name: 'Ward'
      reference_factory author_name: 'Fisher'
      Sunspot.commit

      expect(described_class.solr_search { keywords 'Ward' }.results).to eq [reference]
    end

    it "returns an empty array if nothing is found for a given year and author_name" do
      reference_factory author_name: 'Bolton', citation_year: '2010'
      reference_factory author_name: 'Bolton', citation_year: '1995'
      reference_factory author_name: 'Fisher', citation_year: '2011'
      reference_factory author_name: 'Fisher', citation_year: '1996'
      Sunspot.commit

      expect(described_class.solr_search {
        with(:year).between(2012..2013)
        keywords 'Fisher'
      }.results).to be_empty
    end

    it "returns the one reference for a given year and author_name" do
      reference_factory author_name: 'Bolton', citation_year: '2010'
      reference_factory author_name: 'Bolton', citation_year: '1995'
      reference_factory author_name: 'Fisher', citation_year: '2011'
      reference = reference_factory author_name: 'Fisher', citation_year: '1996'
      Sunspot.commit

      expect(described_class.solr_search {
        with(:year).between(1996..1996)
        keywords 'Fisher'
      }.results).to eq [reference]
    end

    it "searches citation years" do
      with_letter = reference_factory author_name: 'Bolton', citation_year: '2010b'
      reference_factory author_name: 'Bolton', citation_year: '2010'
      Sunspot.commit

      expect(described_class.solr_search {
        keywords '2010b'
      }.results).to eq [with_letter]
    end
  end

  describe "#author_search" do
    let(:author_names_query) { "Bolton, B;" }

    it "calls `References::Search::AuthorSearch`" do
      expect(References::Search::AuthorSearch).to receive(:new)
        .with(author_names_query, nil).and_call_original
      described_class.author_search author_names_query
    end
  end

  describe "#extract_keyword_params" do
    let(:keyword_string) { "Atta" }

    it "calls `References::Search::ExtractKeywords`" do
      expect(References::Search::ExtractKeywords).to receive(:new)
        .with(keyword_string).and_call_original
      described_class.extract_keyword_params keyword_string
    end
  end
end
