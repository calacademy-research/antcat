# frozen_string_literal: true

require 'rails_helper'

describe References::Search::Fulltext, :search do
  describe "#call" do
    describe 'searching with keywords' do
      describe 'keyword: `title`' do
        let!(:pescatore_reference) { create :any_reference, title: 'Pizza Pescatore' }
        let!(:capricciosa_reference) { create :any_reference, title: 'Pizza Capricciosa' }

        before do
          Sunspot.commit
        end

        specify do
          expect(described_class[title: 'Pescatore']).to match_array [pescatore_reference]
          expect(described_class[title: 'Capricciosa']).to match_array [capricciosa_reference]
          expect(described_class[title: 'pizza']).to match_array [pescatore_reference, capricciosa_reference]
        end
      end

      describe 'keyword: `author`' do
        let!(:bolton_reference) { create :any_reference, author_string: 'Bolton' }
        let!(:fisher_reference) { create :any_reference, author_string: 'Fisher' }

        before do
          Sunspot.commit
        end

        specify do
          expect(described_class[author: 'Bolton']).to match_array [bolton_reference]
          expect(described_class[author: 'Fisher']).to match_array [fisher_reference]
        end
      end

      describe 'keywords: `start_year`, `end_year` and `year`' do
        before do
          create :any_reference, citation_year: '1994'
          create :any_reference, citation_year: '1995'
          create :any_reference, citation_year: '1996a'
          create :any_reference, citation_year: '1998'
          Sunspot.commit
        end

        it "returns entries in between the start year and the end year" do
          results = described_class[start_year: 1995, end_year: 1996]
          expect(results.map(&:year)).to match_array [1995, 1996]
        end
      end

      describe "keyword: `year`" do
        let!(:reference) { create :any_reference, citation_year: '2004' }

        before do
          create :any_reference, citation_year: '2003'
          Sunspot.commit
        end

        specify do
          expect(described_class[year: 2004]).to eq [reference]
        end
      end

      describe 'keyword: `reference_type`' do
        let!(:unknown) { create :unknown_reference }
        let!(:article) { create :article_reference }
        let!(:nested) { create :nested_reference, nesting_reference: article }

        before do
          Sunspot.commit
        end

        specify do
          expect(described_class[]).to match_array [unknown, nested, article]
          expect(described_class[reference_type: :unknown]).to eq [unknown]
          expect(described_class[reference_type: :nested]).to eq [nested]
        end
      end

      describe 'keyword: `doi`' do
        let!(:doi) { "10.11865/zs.201806" }
        let!(:reference) { create :article_reference, doi: doi }

        before do
          create :article_reference # Not matching.
          Sunspot.commit
        end

        specify { expect(described_class[doi: doi]).to eq [reference] }
      end
    end

    describe 'searching with free-form text (`keywords` param)' do
      describe 'notes' do
        let!(:with_public_notes) { create :any_reference, public_notes: 'public' }
        let!(:with_editor_notes) { create :any_reference, editor_notes: 'editor' }
        let!(:with_taxonomic_notes) { create :any_reference, taxonomic_notes: 'taxonomic' }

        before do
          Sunspot.commit
        end

        specify do
          expect(described_class[keywords: 'public']).to eq [with_public_notes]
          expect(described_class[keywords: 'editor']).to eq [with_editor_notes]
          expect(described_class[keywords: 'taxonomic']).to eq [with_taxonomic_notes]
        end
      end

      describe 'author names' do
        context "when author contains German diacritics" do
          let!(:reference) { create :any_reference, author_string: 'Hölldobler' }

          before { Sunspot.commit }

          specify { expect(described_class[keywords: 'Hölldobler']).to eq [reference] }
          specify { expect(described_class[keywords: 'holldobler']).to eq [reference] }
        end

        context "when author contains Hungarian diacritics" do
          let!(:reference) { create :any_reference, author_string: 'Csősz' }

          before { Sunspot.commit }

          specify { expect(described_class[keywords: 'Csősz']).to eq [reference] }
          specify { expect(described_class[keywords: 'csosz']).to eq [reference] }
        end
      end

      describe 'journal names (`ArticleReference`s)' do
        let!(:reference) { create :article_reference, journal: create(:journal, name: 'Abc') }

        before do
          create :article_reference # Not matching.
          Sunspot.commit
        end

        it 'searches in `journals.name`' do
          expect(described_class[keywords: 'Abc']).to eq [reference]
        end
      end

      describe 'publisher name (`BookReference`s)' do
        let!(:reference) { create :book_reference, publisher: create(:publisher, name: 'Abc') }

        before do
          create :book_reference # Not matching.
          Sunspot.commit
        end

        it 'searches in `publishers.name`' do
          expect(described_class[keywords: 'Abc']).to eq [reference]
        end
      end

      describe 'citations (`UnknownReference`s)' do
        let!(:reference) { create :unknown_reference, citation: 'Abc' }

        before do
          create :unknown_reference # Not matching.
          Sunspot.commit
        end

        it 'searches in `citations`' do
          expect(described_class[keywords: 'Abc']).to eq [reference]
        end
      end
    end
  end

  describe "ignored characters" do
    context "when search query contains ').'" do
      let!(:title) { 'Tetramoriini (Hymenoptera Formicidae).' }
      let!(:reference) { create :any_reference, title: title }

      before { Sunspot.commit }

      specify do
        expect(described_class[keywords: title]).to eq [reference]
        expect(described_class[title: title]).to eq [reference]
      end
    end

    context "when search query contains '&'" do
      let!(:reference) do
        bolton = create :author_name, name: 'Bolton, B.'
        fisher = create :author_name, name: 'Fisher, B.'

        create :any_reference, author_names: [bolton, fisher], citation_year: '1970a'
      end

      before { Sunspot.commit }

      specify { expect(described_class[keywords: "Fisher & Bolton 1970a"]).to eq [reference] }
    end

    context "when search query contains 'et al.'" do
      let!(:reference) do
        bolton = create :author_name, name: 'Bolton, B.'
        fisher = create :author_name, name: 'Fisher, B.'
        ward = create :author_name, name: 'Ward, P.S.'

        create :any_reference, author_names: [bolton, fisher, ward], citation_year: '1970a'
      end

      before { Sunspot.commit }

      specify { expect(described_class[keywords: "Fisher, et al. 1970a"]).to eq [reference] }
    end

    describe "replacing some characters to make search work" do
      let!(:title) { '*Camponotus piceus* (Leach, 1825), decouverte Viroin-Hermeton' }
      let!(:reference) { create :any_reference, title: title }

      it "handles this reference with asterixes and a hyphen" do
        Sunspot.commit

        expect(described_class[keywords: title]).to eq [reference]
        expect(described_class[title: title]).to eq [reference]
      end
    end
  end
end
