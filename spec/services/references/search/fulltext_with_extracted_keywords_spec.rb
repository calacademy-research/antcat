require "spec_helper"

describe References::Search::FulltextWithExtractedKeywords do
  describe "#call" do
    describe "Search parameters", search: true do
      describe "Authors" do
        context 'when nothing is found for the author names' do
          it "returns an empty array" do
            expect(described_class[q: "author:Balou"]).to be_empty
          end
        end

        context 'when a given author_name exists' do
          let!(:bolton) { create :author_name, name: "Bolton Barry" }
          let!(:reference) { create :book_reference, author_names: [bolton] }

          before do
            create :book_reference, author_names: [create(:author_name, name: 'Fisher')]
            Sunspot.commit
          end

          it "finds the reference for " do
            expect(described_class[q: "author:'#{bolton.name}'"]).to eq [reference]
          end
        end

        it "finds the reference with both author names, but not just one" do
          bolton = create :author_name, name: 'Bolton'
          fisher = create :author_name, name: 'Fisher'
          create :reference, author_names: [bolton]
          create :reference, author_names: [fisher]
          reference = create :reference, author_names: [bolton, fisher]
          Sunspot.commit

          expect(described_class[q: 'author:"Bolton Fisher"']).to eq [reference]
        end
      end

      describe 'Fulltext' do
        describe 'Notes' do
          it 'searches in public notes' do
            reference = reference_factory author_name: 'Hölldobler', public_notes: 'abcdef'
            reference_factory author_name: 'Hölldobler', public_notes: 'fedcba' # Not matching.
            Sunspot.commit

            expect(described_class[q: 'abcdef']).to eq [reference]
          end

          it 'searches in editor notes' do
            reference = reference_factory author_name: 'Hölldobler', editor_notes: 'abcdef'
            reference_factory author_name: 'Hölldobler', editor_notes: 'fedcba' # Not matching.
            Sunspot.commit

            expect(described_class[q: 'abcdef']).to eq [reference]
          end

          it 'searches in taxonomic notes' do
            reference = reference_factory author_name: 'Hölldobler', taxonomic_notes: 'abcdef'
            reference_factory author_name: 'Hölldobler', taxonomic_notes: 'fedcba' # Not matching.
            Sunspot.commit

            expect(described_class[q: 'abcdef']).to eq [reference]
          end
        end

        describe 'Author names' do
          let!(:reference) { reference_factory author_name: 'Hölldobler' }

          before { Sunspot.commit }

          it 'handles diacritics in the search term' do
            expect(described_class[q: 'Hölldobler']).to eq [reference]
          end

          it 'substitutes diacritics with English letters' do
            expect(described_class[q: 'holldobler']).to eq [reference]
          end
        end

        describe 'Journal name' do
          let!(:reference) { create :article_reference, journal: create(:journal, name: 'Abc') }

          before do
            create :article_reference # Not matching.
            Sunspot.commit
          end

          it 'searches journal names' do
            expect(described_class[q: 'Abc']).to eq [reference]
          end
        end

        describe 'Publisher name' do
          let!(:reference) { create :book_reference, publisher: create(:publisher, name: 'Abc') }

          before do
            create :article_reference # Not matching.
            Sunspot.commit
          end

          it 'searches publisher names' do
            expect(described_class[q: 'Abc']).to eq [reference]
          end
        end

        describe 'Citation (for Unknown references)' do
          let!(:reference) { create :unknown_reference, citation: 'Abc' }

          before do
            create :article_reference # Not matching.
            Sunspot.commit
          end

          it 'searches in citations' do
            expect(described_class[q: 'Abc']).to eq [reference]
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
