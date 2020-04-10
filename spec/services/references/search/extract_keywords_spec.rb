# frozen_string_literal: true

require 'rails_helper'

describe References::Search::ExtractKeywords do
  describe "#call" do
    it "doesn't extract anything if there is nothing to extact" do
      expect(described_class["Bolton 2003"]).to eq(
        keywords: "Bolton 2003"
      )
    end

    describe "keyword: `year`" do
      it "extracts single years" do
        expect(described_class["Bolton year:2003"]).to eq(
          year: "2003",
          keywords: "Bolton"
        )
      end

      it "extracts year ranges" do
        expect(described_class["Bolton year:2003-2015"]).to eq(
          start_year: "2003",
          end_year: "2015",
          keywords: "Bolton"
        )
      end
    end

    describe 'keyword: [reference] `type`' do
      specify do
        expect(described_class["Bolton type:nested"]).to eq(
          reference_type: :nested,
          keywords: "Bolton"
        )
      end
    end

    describe 'keyword: `author`' do
      specify do
        expect(described_class["Ants Book author:Bolton"]).to eq(
          author: "Bolton",
          keywords: "Ants Book"
        )
      end

      describe "`author` keywords containing spaces" do
        it "handles double quotes" do
          expect(described_class['Ants Book author:"Barry Bolton"']).to eq(
            author: "Barry Bolton",
            keywords: "Ants Book"
          )
        end

        it "handles single quotes" do
          expect(described_class["Ants Book author:'Barry Bolton'"]).to eq(
            author: "Barry Bolton",
            keywords: "Ants Book"
          )
        end
      end

      describe "`author` keywords not wrapped in quotes" do
        it "handles hyphens" do
          expect(described_class['author:Barry-Bolton']).to eq(
            author: "Barry-Bolton",
            keywords: ""
          )
        end

        it "handles diacritics" do
          expect(described_class['author:Hölldobler']).to eq(
            author: "Hölldobler",
            keywords: ""
          )
        end

        it "doesn't break if more search term are added after the `author` keyword" do
          expect(described_class["author:Hölldobler random string"]).to eq(
            author: "Hölldobler",
            keywords: "random string"
          )
        end
      end
    end

    describe 'keyword: `doi`' do
      specify do
        expect(described_class["Ants Book doi:10.11865/zs.201806"]).to eq(
          doi: "10.11865/zs.201806",
          keywords: "Ants Book"
        )
      end
    end

    it "handles multiple keywords" do
      expect(described_class['Ants Book author:"Barry Bolton" year:2003 type:nested']).to eq(
        author: "Barry Bolton",
        year: "2003",
        reference_type: :nested,
        keywords: "Ants Book"
      )
    end

    it "handles keywords without a search term" do
      expect(described_class['year:2003']).to eq(
        year: "2003",
        keywords: ""
      )
    end

    it "ignores a single space after the colon after a keyword" do
      expect(described_class['author: Wilson']).to eq(
        author: "Wilson",
        keywords: ""
      )
    end

    it "ignores capitalization of keywords" do
      expect(described_class['Author:Wilson']).to eq(
        author: "Wilson",
        keywords: ""
      )
    end
  end
end
