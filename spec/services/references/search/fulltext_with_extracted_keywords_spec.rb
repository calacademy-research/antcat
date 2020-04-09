# frozen_string_literal: true

require 'rails_helper'

describe References::Search::FulltextWithExtractedKeywords do
  describe "#call", :search do
    describe "searching by author" do
      context 'when there are no matches' do
        specify { expect(described_class["author:Balou"]).to be_empty }
      end

      context 'when there are matches' do
        let!(:bolton) { create :author_name, name: "Bolton Barry" }

        context 'when searching for a single author' do
          let!(:reference) { create :any_reference, author_names: [bolton] }

          before do
            Sunspot.commit
          end

          it "returns references by the author" do
            expect(described_class["author:'#{bolton.name}'"]).to eq [reference]
          end
        end

        context 'when searching for multiple authors' do
          let!(:fisher) { create :author_name, name: "Brian Fisher" }
          let!(:reference) { create :any_reference, author_names: [bolton, fisher] }

          before do
            Sunspot.commit
          end

          it "returns references by the authors" do
            expect(described_class['author:"Bolton Fisher"']).to eq [reference]
          end
        end
      end
    end

    # TODO: May be duplicated and/or not needed.
    describe "searching for text and/or years" do
      it "extracts the starting and ending years" do
        expect(References::Search::Fulltext).to receive(:new).
          with(hash_including(keywords: '', start_year: "1992", end_year: "1993")).
          and_call_original
        described_class['year:1992-1993']
      end

      it "extracts the starting year" do
        expect(References::Search::Fulltext).to receive(:new).
          with(hash_including(keywords: '', year: "1992")).
          and_call_original
        described_class['year:1992']
      end

      it "can distinguish between years and citation years" do
        expect(References::Search::Fulltext).to receive(:new).
          with(hash_including(keywords: '1970a', year: "1970")).
          and_call_original
        described_class['1970a year:1970']
      end
    end

    describe "filtering nested reference types" do
      it "returns only references of type nested" do
        expect(References::Search::Fulltext).to receive(:new).
          with(hash_including(keywords: 'Monroe', reference_type: :nested)).
          and_call_original
        described_class['Monroe type:nested']
      end
    end
  end
end
