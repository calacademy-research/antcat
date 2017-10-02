require "spec_helper"

describe References::Search::Fulltext, search: true do
  # Throw in a MissingReference to make sure it's not returned.
  before { create :missing_reference }

  describe "#call" do
    describe 'searching with `start_year`, `end_year` and `year`' do
      before do
        reference_factory author_name: 'Bolton', citation_year: '1994'
        reference_factory author_name: 'Bolton', citation_year: '1995'
        reference_factory author_name: 'Bolton', citation_year: '1996'
        reference_factory author_name: 'Bolton', citation_year: '1997'
        reference_factory author_name: 'Bolton', citation_year: '1998'
        Sunspot.commit
      end

      it "returns an empty array if nothing is found for year" do
        results = described_class[keywords: '', start_year: 1992, end_year: 1993]
        expect(results).to be_empty
      end

      it "finds entries in between the start year and the end year (inclusive)" do
        results = described_class[keywords: '', start_year: 1995, end_year: 1996]
        expect(results.map(&:year)).to match_array [1995, 1996]
      end

      it "finds references in the year of the end range, even if they have extra characters" do
        reference_factory author_name: 'Bolton', citation_year: '2004.'
        Sunspot.commit

        results = described_class[keywords: '', year: 2004]
        expect(results.map(&:year)).to match_array [2004]
      end
    end

    describe "Year and fulltext" do
      it "works" do
        atta2004 = create :book_reference, title: 'Atta', citation_year: '2004'
        atta2003 = create :book_reference, title: 'Atta', citation_year: '2003'
        formica2004 = create :book_reference, title: 'Formica', citation_year: '2003'
        Sunspot.commit

        expect(described_class[keywords: 'atta', year: 2004]).to eq [atta2004]
      end
    end
  end

  describe 'searching with `reference_type`' do
    it "applies the :unknown :reference_type that's passed" do
      unknown = create :unknown_reference
      create :article_reference # known
      Sunspot.commit

      expect(described_class[q: "bolton", reference_type: :unknown]).to eq [unknown]
    end

    it "applies the :nomissing :reference_type that's passed" do
      expect(MissingReference.count).to be > 0
      reference = create :article_reference
      Sunspot.commit

      expect(described_class[q: 'bolton', reference_type: :nomissing]).to eq [reference]
    end

    it "applies the :nested :reference_type that's passed" do
      nested = create :nested_reference
      create :unknown_reference # unnested
      Sunspot.commit

      expect(described_class[q: 'bolton', reference_type: :nested]).to eq [nested]
    end
  end

  describe "replacing some characters to make search work" do
    it "handles this reference with asterixes and a hyphen" do
      title = '*Camponotus piceus* (Leach, 1825), decouverte Viroin-Hermeton'
      reference = create :article_reference, title: title
      Sunspot.commit

      expect(described_class[title: title]).to eq [reference]
    end
  end
end
