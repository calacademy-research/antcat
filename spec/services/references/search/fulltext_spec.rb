require "spec_helper"

describe References::Search::Fulltext, :search do
  describe "#call" do
    describe 'searching with `start_year`, `end_year` and `year`' do
      before do
        create :reference, citation_year: '1994'
        create :reference, citation_year: '1995'
        create :reference, citation_year: '1996a'
        create :reference, citation_year: '1997'
        create :reference, citation_year: '1998'
        Sunspot.commit
      end

      it "returns entries in between the start year and the end year" do
        results = described_class[keywords: '', start_year: 1995, end_year: 1996]
        expect(results.map(&:year)).to match_array [1995, 1996]
      end
    end

    describe "year" do
      let!(:reference) { create :reference, citation_year: '2004' }

      before do
        create :reference, citation_year: '2003'
        Sunspot.commit
      end

      specify do
        expect(described_class[year: 2004]).to eq [reference]
      end
    end

    describe 'notes' do
      let!(:public) { create :reference, public_notes: 'public' }
      let!(:editor) { create :reference, editor_notes: 'editor' }
      let!(:taxonomic) { create :reference, taxonomic_notes: 'taxonomic' }

      before do
        Sunspot.commit
      end

      specify do
        expect(described_class[keywords: 'public']).to eq [public]
        expect(described_class[keywords: 'editor']).to eq [editor]
        expect(described_class[keywords: 'taxonomic']).to eq [taxonomic]
      end
    end

    describe 'author names' do
      context "when author contains German diacritics" do
        let!(:reference) { reference_factory author_name: 'Hölldobler' }

        before { Sunspot.commit }

        specify { expect(described_class[keywords: 'Hölldobler']).to eq [reference] }
        specify { expect(described_class[keywords: 'holldobler']).to eq [reference] }
      end

      context "when author contains Hungarian diacritics" do
        let!(:reference) { reference_factory author_name: 'Csősz' }

        before { Sunspot.commit }

        specify { expect(described_class[keywords: 'Csősz']).to eq [reference] }
        specify { expect(described_class[keywords: 'csosz']).to eq [reference] }
      end
    end

    describe 'journal names' do
      let!(:reference) { create :article_reference, journal: create(:journal, name: 'Abc') }

      before do
        create :article_reference # Not matching.
        Sunspot.commit
      end

      it 'searches journal names' do
        expect(described_class[keywords: 'Abc']).to eq [reference]
      end
    end

    describe 'publisher name' do
      let!(:reference) { create :book_reference, publisher: create(:publisher, name: 'Abc') }

      before do
        create :article_reference # Not matching.
        Sunspot.commit
      end

      it 'searches publisher names' do
        expect(described_class[keywords: 'Abc']).to eq [reference]
      end
    end

    describe 'citations (for Unknown references)' do
      let!(:reference) { create :unknown_reference, citation: 'Abc' }

      before do
        create :article_reference # Not matching.
        Sunspot.commit
      end

      it 'searches in citations' do
        expect(described_class[keywords: 'Abc']).to eq [reference]
      end
    end
  end

  describe 'searching with `reference_type`' do
    let!(:unknown) { create :unknown_reference }
    let!(:missing) { create :missing_reference }
    let!(:article) { create :article_reference }
    let!(:nested) { create :nested_reference, nesting_reference: article }

    before do
      Sunspot.commit
    end

    specify do
      expect(described_class[reference_type: :unknown]).to eq [unknown]
      expect(described_class[reference_type: :nomissing]).to match_array [unknown, nested, article]
      expect(described_class[reference_type: :nested]).to eq [nested]
    end
  end

  describe "replacing some characters to make search work" do
    let!(:title) { '*Camponotus piceus* (Leach, 1825), decouverte Viroin-Hermeton' }
    let!(:reference) { create :reference, title: title }

    it "handles this reference with asterixes and a hyphen" do
      Sunspot.commit

      expect(described_class[title: title]).to eq [reference]
    end
  end
end
