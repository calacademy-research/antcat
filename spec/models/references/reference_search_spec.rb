# TODO cleanup spec.

require 'spec_helper'

describe Reference do
  # Throw in a MissingReference to make sure it's not returned.
  before { create :missing_reference }

  describe ".do_search, .perform_search" do
    describe "Search parameters" do
      describe "Authors", search: true do
        it "returns an empty array if nothing is found for the author names" do
          expect(described_class.do_search(q: "author:Balou")).to be_empty
        end

        it "finds the reference for a given author_name if it exists" do
          bolton = create :author_name, name: "Bolton Barry"
          reference = create :book_reference, author_names: [bolton]
          create :book_reference, author_names: [create(:author_name, name: 'Fisher')]
          Sunspot.commit

          results = described_class.do_search q: "author:'#{bolton.name}'"
          expect(results).to eq [reference]
        end

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

        it "finds the reference with both author names, but not just one" do
          bolton = create :author_name, name: 'Bolton'
          fisher = create :author_name, name: 'Fisher'
          create :reference, author_names: [bolton]
          create :reference, author_names: [fisher]
          bolton_fisher_reference = create :reference, author_names: [bolton, fisher]
          Sunspot.commit

          expect(described_class.do_search(q: 'author:"Bolton Fisher"')).to eq [bolton_fisher_reference]
        end
      end

      describe 'Fulltext', search: true do
        describe 'Notes' do
          it 'searches in public notes' do
            matching_reference = reference_factory author_name: 'Hölldobler', public_notes: 'abcdef'
            reference_factory author_name: 'Hölldobler', public_notes: 'fedcba' # unmatching_reference
            Sunspot.commit

            expect(described_class.do_search(q: 'abcdef')).to eq [matching_reference]
          end

          it 'searches in editor notes' do
            matching_reference = reference_factory author_name: 'Hölldobler', editor_notes: 'abcdef'
            reference_factory author_name: 'Hölldobler', editor_notes: 'fedcba' # unmatching_reference
            Sunspot.commit

            expect(described_class.do_search(q: 'abcdef')).to eq [matching_reference]
          end

          it 'searches in taxonomic notes' do
            matching_reference = reference_factory author_name: 'Hölldobler', taxonomic_notes: 'abcdef'
            reference_factory author_name: 'Hölldobler', taxonomic_notes: 'fedcba' # unmatching_reference
            Sunspot.commit

            expect(described_class.do_search(q: 'abcdef')).to eq [matching_reference]
          end
        end

        describe 'Author names', search: true do
          let!(:reference) { reference_factory author_name: 'Hölldobler' }
          before { Sunspot.commit }

          it 'handles diacritics in the search term' do
            expect(described_class.do_search(q: 'Hölldobler')).to eq [reference]
          end

          it 'substitutes diacritics with English letters' do
            expect(described_class.do_search(q: 'holldobler')).to eq [reference]
          end
        end

        describe 'Journal name', search: true do
          it 'searches journal names' do
            matching_reference = reference_factory author_name: 'Hölldobler',
              journal: create(:journal, name: 'Journal')
            reference_factory author_name: 'Hölldobler' # unmatching_reference
            Sunspot.commit

            expect(described_class.do_search(q: 'journal')).to eq [matching_reference]
          end
        end

        describe 'Publisher name', search: true do
          it 'searches publisher names' do
            matching_reference = reference_factory author_name: 'Hölldobler',
              publisher: create(:publisher, name: 'Publisher')
            reference_factory author_name: 'Hölldobler' # unmatching_reference
            Sunspot.commit

            expect(described_class.do_search(q: 'Publisher')).to eq [matching_reference]
          end
        end

        describe 'Citation (for Unknown references)', search: true do
          it 'searches in citations' do
            matching_reference = reference_factory author_name: 'Hölldobler', citation: 'Citation'
            unmatching_reference = reference_factory author_name: 'Hölldobler'
            Sunspot.commit

            expect(described_class.do_search(q: 'Citation')).to eq [matching_reference]
          end
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

  describe ".do_search" do
    describe "Searching for text and/or years" do
      it "extracts the starting and ending years" do
        expect(described_class).to receive(:fulltext_search)
          .with hash_including(keywords: '', start_year: "1992", end_year: "1993")
        described_class.do_search q: 'year:1992-1993'
      end

      it "extracts the starting year" do
        expect(described_class).to receive(:fulltext_search)
          .with hash_including(keywords: '', year: "1992")
        described_class.do_search q: 'year:1992'
      end

      it "converts the query string", pending: true do
        pending "downcasing/transliteration removed valid search results"
        # TODO config solr
        expect(described_class).to receive(:fulltext_search)
          .with hash_including(keywords: 'andre')
        described_class.do_search q: 'André'
      end

      it "can distinguish between years and citation years" do
        expect(described_class).to receive(:fulltext_search)
          .with hash_including(keywords: '1970a', year: "1970")
        described_class.do_search q: '1970a year:1970'
      end
    end

    describe "Filtering unknown reference types" do
      context "when type:unknown is passed as the search term" do
        it "returns only references of type unknown" do
          expect(described_class).to receive(:fulltext_search)
            .with hash_including(keywords: 'Monroe', reference_type: :unknown)
          described_class.do_search q: 'Monroe type:unknown'
        end
      end
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
