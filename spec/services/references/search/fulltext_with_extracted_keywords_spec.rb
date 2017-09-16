require "spec_helper"

describe References::Search::FulltextWithExtractedKeywords do
  # Throw in a MissingReference to make sure it's not returned.
  before { create :missing_reference }

  describe "#call" do
    describe "Search parameters" do
      describe "Authors", search: true do
        it "returns an empty array if nothing is found for the author names" do
          expect(described_class[q: "author:Balou"]).to be_empty
        end

        it "finds the reference for a given author_name if it exists" do
          bolton = create :author_name, name: "Bolton Barry"
          reference = create :book_reference, author_names: [bolton]
          create :book_reference, author_names: [create(:author_name, name: 'Fisher')]
          Sunspot.commit

          results = described_class[q: "author:'#{bolton.name}'"]
          expect(results).to eq [reference]
        end

        it "finds the reference with both author names, but not just one" do
          bolton = create :author_name, name: 'Bolton'
          fisher = create :author_name, name: 'Fisher'
          create :reference, author_names: [bolton]
          create :reference, author_names: [fisher]
          bolton_fisher_reference = create :reference, author_names: [bolton, fisher]
          Sunspot.commit

          expect(described_class[q: 'author:"Bolton Fisher"']).to eq [bolton_fisher_reference]
        end
      end

      describe 'Fulltext', search: true do
        describe 'Notes' do
          it 'searches in public notes' do
            matching_reference = reference_factory author_name: 'Hölldobler', public_notes: 'abcdef'
            reference_factory author_name: 'Hölldobler', public_notes: 'fedcba' # unmatching_reference
            Sunspot.commit

            expect(described_class[q: 'abcdef']).to eq [matching_reference]
          end

          it 'searches in editor notes' do
            matching_reference = reference_factory author_name: 'Hölldobler', editor_notes: 'abcdef'
            reference_factory author_name: 'Hölldobler', editor_notes: 'fedcba' # unmatching_reference
            Sunspot.commit

            expect(described_class[q: 'abcdef']).to eq [matching_reference]
          end

          it 'searches in taxonomic notes' do
            matching_reference = reference_factory author_name: 'Hölldobler', taxonomic_notes: 'abcdef'
            reference_factory author_name: 'Hölldobler', taxonomic_notes: 'fedcba' # unmatching_reference
            Sunspot.commit

            expect(described_class[q: 'abcdef']).to eq [matching_reference]
          end
        end

        describe 'Author names', search: true do
          let!(:reference) { reference_factory author_name: 'Hölldobler' }
          before { Sunspot.commit }

          it 'handles diacritics in the search term' do
            expect(described_class[q: 'Hölldobler']).to eq [reference]
          end

          it 'substitutes diacritics with English letters' do
            expect(described_class[q: 'holldobler']).to eq [reference]
          end
        end

        describe 'Journal name', search: true do
          it 'searches journal names' do
            matching_reference = reference_factory author_name: 'Hölldobler',
              journal: create(:journal, name: 'Journal')
            reference_factory author_name: 'Hölldobler' # unmatching_reference
            Sunspot.commit

            expect(described_class[q: 'journal']).to eq [matching_reference]
          end
        end

        describe 'Publisher name', search: true do
          it 'searches publisher names' do
            matching_reference = reference_factory author_name: 'Hölldobler',
              publisher: create(:publisher, name: 'Publisher')
            reference_factory author_name: 'Hölldobler' # unmatching_reference
            Sunspot.commit

            expect(described_class[q: 'Publisher']).to eq [matching_reference]
          end
        end

        describe 'Citation (for Unknown references)', search: true do
          it 'searches in citations' do
            matching_reference = reference_factory author_name: 'Hölldobler', citation: 'Citation'
            unmatching_reference = reference_factory author_name: 'Hölldobler'
            Sunspot.commit

            expect(described_class[q: 'Citation']).to eq [matching_reference]
          end
        end
      end
    end

    # TODO may be duplicated and/or not needed.
    describe "Searching for text and/or years" do
      it "extracts the starting and ending years" do
        expect(References::Search::Fulltext).to receive(:new)
          .with(hash_including(keywords: '', start_year: "1992", end_year: "1993"))
          .and_call_original
        described_class[q: 'year:1992-1993']
      end

      it "extracts the starting year" do
        expect(References::Search::Fulltext).to receive(:new)
          .with(hash_including(keywords: '', year: "1992"))
          .and_call_original
        described_class[q: 'year:1992']
      end

      it "converts the query string", pending: true do
        pending "downcasing/transliteration removed valid search results"
        # TODO config solr
        expect(References::Search::Fulltext).to receive(:new)
          .with(hash_including(keywords: 'andre'))
          .and_call_original
        described_class[q: 'André']
      end

      it "can distinguish between years and citation years" do
        expect(References::Search::Fulltext).to receive(:new)
          .with(hash_including(keywords: '1970a', year: "1970"))
          .and_call_original
        described_class[q: '1970a year:1970']
      end
    end

    # TODO may be duplicated and/or not needed.
    describe "Filtering unknown reference types" do
      context "when type:unknown is passed as the search term" do
        it "returns only references of type unknown" do
          expect(References::Search::Fulltext).to receive(:new)
            .with(hash_including(keywords: 'Monroe', reference_type: :unknown))
            .and_call_original
          described_class[q: 'Monroe type:unknown']
        end
      end
    end
  end
end
