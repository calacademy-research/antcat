# frozen_string_literal: true

require 'rails_helper'

describe References::Search::ExtractKeywords do
  describe References::Search::ExtractKeywords::Extracted do
    describe '#to_solr' do
      subject(:struct) { described_class.new(freetext: '', year: 2000, title: nil) }

      it 'removes blanks' do
        expect(struct.to_solr).to eq(year: 2000)
      end
    end

    describe '#searching_with_keywords?' do
      context 'with keywords only`' do
        subject(:struct) { described_class.new(year: 2000) }

        specify { expect(struct.searching_with_keywords?).to eq true }
      end

      context 'with keywords and blank `freetext`' do
        subject(:struct) { described_class.new(freetext: '', year: 2000) }

        specify { expect(struct.searching_with_keywords?).to eq true }
      end

      context 'with `freetext` only' do
        subject(:struct) { described_class.new(freetext: 'pizza') }

        specify { expect(struct.searching_with_keywords?).to eq false }
      end
    end
  end

  describe "#call" do
    it "doesn't extract anything if there is nothing to extract" do
      expect(described_class["Bolton 2003"]).to eq(
        described_class::Extracted.new(
          freetext: "Bolton 2003"
        )
      )
    end

    describe "keyword: `year`" do
      it "extracts single years" do
        expect(described_class["Bolton year:2003"]).to eq(
          described_class::Extracted.new(
            year: "2003",
            freetext: "Bolton"
          )
        )
      end

      it "extracts year ranges" do
        expect(described_class["Bolton year:2003-2015"]).to eq(
          described_class::Extracted.new(
            start_year: "2003",
            end_year: "2015",
            freetext: "Bolton"
          )
        )
      end
    end

    describe 'keyword: [reference] `type`' do
      specify do
        expect(described_class["Bolton type:nested"]).to eq(
          described_class::Extracted.new(
            reference_type: 'nested',
            freetext: "Bolton"
          )
        )
      end
    end

    describe 'keyword: `author`' do
      specify do
        expect(described_class["Ants Book author:Bolton"]).to eq(
          described_class::Extracted.new(
            author: "Bolton",
            freetext: "Ants Book"
          )
        )
      end

      describe "`author` keywords containing spaces" do
        it "handles double quotes" do
          expect(described_class['Ants Book author:"Barry Bolton"']).to eq(
            described_class::Extracted.new(
              author: "Barry Bolton",
              freetext: "Ants Book"
            )
          )
        end

        it "handles single quotes" do
          expect(described_class["Ants Book author:'Barry Bolton'"]).to eq(
            described_class::Extracted.new(
              author: "Barry Bolton",
              freetext: "Ants Book"
            )
          )
        end
      end

      describe "`author` keywords not wrapped in quotes" do
        it "handles hyphens" do
          expect(described_class['author:Barry-Bolton']).to eq(
            described_class::Extracted.new(
              author: "Barry-Bolton",
              freetext: ""
            )
          )
        end

        it "handles diacritics" do
          expect(described_class['author:Hölldobler']).to eq(
            described_class::Extracted.new(
              author: "Hölldobler",
              freetext: ""
            )
          )
        end

        it "doesn't break if more search term are added after the `author` keyword" do
          expect(described_class["author:Hölldobler random string"]).to eq(
            described_class::Extracted.new(
              author: "Hölldobler",
              freetext: "random string"
            )
          )
        end
      end
    end

    describe 'keyword: `doi`' do
      specify do
        expect(described_class["Ants Book doi:10.11865/zs.201806"]).to eq(
          described_class::Extracted.new(
            doi: "10.11865/zs.201806",
            freetext: "Ants Book"
          )
        )
      end
    end

    it "handles multiple keywords" do
      expect(described_class['Ants Book author:"Barry Bolton" year:2003 type:nested']).to eq(
        described_class::Extracted.new(
          author: "Barry Bolton",
          year: "2003",
          reference_type: 'nested',
          freetext: "Ants Book"
        )
      )
    end

    it "handles keywords without a search term" do
      expect(described_class['year:2003']).to eq(
        described_class::Extracted.new(
          year: "2003",
          freetext: ""
        )
      )
    end

    it "ignores capitalization of keywords" do
      expect(described_class['Author:Wilson']).to eq(
        described_class::Extracted.new(
          author: "Wilson",
          freetext: ""
        )
      )
    end
  end
end
