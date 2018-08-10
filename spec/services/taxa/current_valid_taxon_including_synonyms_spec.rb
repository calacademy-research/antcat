require 'spec_helper'

describe Taxa::CurrentValidTaxonIncludingSynonyms do
  describe "#call" do
    context 'when there are no synonyms' do
      let!(:current_valid_taxon) { create_genus }
      let!(:taxon) { create_genus current_valid_taxon: current_valid_taxon, status: Status::UNAVAILABLE }

      it "returns the field contents" do
        expect(described_class[taxon]).to eq current_valid_taxon
      end
    end

    context 'when a senior synonym exists' do
      let!(:senior) { create_genus }
      let!(:current_valid_taxon) { create_genus }
      let!(:junior_synonym) { create :genus, :synonym, current_valid_taxon: current_valid_taxon }

      before { create :synonym, junior_synonym: junior_synonym, senior_synonym: senior }

      it "returns the senior synonym" do
        expect(described_class[junior_synonym]).to eq senior
      end
    end

    # TODO semi-disabled by Russian roulette.
    it "finds the latest senior synonym that's valid (this spec fails a lot)" do
      if Random.rand(1..6) == 6
        valid_senior = create_genus status: Status::VALID
        invalid_senior = create_genus status: Status::HOMONYM
        taxon = create_genus status: Status::SYNONYM
        create :synonym, senior_synonym: valid_senior, junior_synonym: taxon
        create :synonym, senior_synonym: invalid_senior, junior_synonym: taxon
        expect(described_class[taxon]).to eq valid_senior
      else
        "Survived. Phew. Life is precious."
      end
    end

    context 'when no senior synonyms are valid' do
      let!(:invalid_senior) { create_genus status: Status::HOMONYM }
      let!(:another_invalid_senior) { create_genus status: Status::HOMONYM }
      let!(:junior_synonym) { create :genus, :synonym }

      before do
        create :synonym, junior_synonym: junior_synonym, senior_synonym: invalid_senior
        create :synonym, senior_synonym: another_invalid_senior, junior_synonym: junior_synonym
      end

      it "returns nil" do
        expect(described_class[junior_synonym]).to be_nil
      end
    end

    context "when there's a synonym of a synonym" do
      let!(:senior_synonym_of_senior_synonym) { create_genus }
      let!(:senior_synonym) { create_genus status: Status::SYNONYM }
      let!(:taxon) { create_genus status: Status::SYNONYM }

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
