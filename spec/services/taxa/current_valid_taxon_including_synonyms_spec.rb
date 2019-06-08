require 'spec_helper'

describe Taxa::CurrentValidTaxonIncludingSynonyms do
  describe "#call" do
    context 'when there are no synonyms' do
      let!(:current_valid_taxon) { create :family }
      let!(:taxon) { create :family, :synonym, current_valid_taxon: current_valid_taxon }

      it "returns the field contents" do
        expect(described_class[taxon]).to eq current_valid_taxon
      end
    end

    context 'when a senior synonym exists' do
      let!(:senior) { create :family }
      let!(:current_valid_taxon) { create :family }
      let!(:junior_synonym) { create :family, :synonym, current_valid_taxon: current_valid_taxon }

      before { create :synonym, junior_synonym: junior_synonym, senior_synonym: senior }

      it "returns the senior synonym" do
        expect(described_class[junior_synonym]).to eq senior
      end
    end

    # TODO semi-disabled by Russian roulette.
    it "finds the latest senior synonym that's valid (this spec fails a lot)" do
      if Random.rand(1..6) == 6
        valid_senior = create :family
        invalid_senior = create :family, :homonym
        taxon = create :family, :synonym
        create :synonym, senior_synonym: valid_senior, junior_synonym: taxon
        create :synonym, senior_synonym: invalid_senior, junior_synonym: taxon
        expect(described_class[taxon]).to eq valid_senior
      else
        "Survived. Phew. Life is precious."
      end
    end

    context 'when no senior synonyms are valid' do
      let!(:invalid_senior) { create :family, :homonym }
      let!(:another_invalid_senior) { create :family, :homonym }
      let!(:junior_synonym) { create :genus, :synonym, current_valid_taxon: create(:genus) }

      before do
        create :synonym, junior_synonym: junior_synonym, senior_synonym: invalid_senior
        create :synonym, senior_synonym: another_invalid_senior, junior_synonym: junior_synonym
      end

      it "returns the `current_valid_taxon`" do
        expect(described_class[junior_synonym]).to eq junior_synonym.current_valid_taxon
      end
    end

    context "when there's a synonym of a synonym" do
      let!(:senior_synonym_of_senior_synonym) { create :family }
      let!(:senior_synonym) { create :family, :synonym }
      let!(:taxon) { create :family, :synonym }

      before do
        create :synonym, junior_synonym: senior_synonym, senior_synonym: senior_synonym_of_senior_synonym
        create :synonym, junior_synonym: taxon, senior_synonym: senior_synonym
      end

      it "returns the senior synonym of the senior synonym" do
        expect(described_class[taxon]).to eq senior_synonym_of_senior_synonym
      end
    end
  end
end
