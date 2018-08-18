require "spec_helper"

describe References::Search::FulltextWithExtractedKeywords do
  describe "#call", :search do
    describe "authors" do
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

    # TODO may be duplicated and/or not needed.
    describe "searching for text and/or years" do
      it "extracts the starting and ending years" do
        expect(References::Search::Fulltext).to receive(:new).
          with(hash_including(keywords: '', start_year: "1992", end_year: "1993")).
          and_call_original
        described_class[q: 'year:1992-1993']
      end

      it "extracts the starting year" do
        expect(References::Search::Fulltext).to receive(:new).
          with(hash_including(keywords: '', year: "1992")).
          and_call_original
        described_class[q: 'year:1992']
      end

      it "can distinguish between years and citation years" do
        expect(References::Search::Fulltext).to receive(:new).
          with(hash_including(keywords: '1970a', year: "1970")).
          and_call_original
        described_class[q: '1970a year:1970']
      end
    end

    describe "filtering unknown reference types" do
      it "returns only references of type unknown" do
        expect(References::Search::Fulltext).to receive(:new).
          with(hash_including(keywords: 'Monroe', reference_type: :unknown)).
          and_call_original
        described_class[q: 'Monroe type:unknown']
      end
    end
  end
end
