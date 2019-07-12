require "spec_helper"

describe Taxa::TaxonStatus do
  include TestLinksHelpers

  describe "#call" do
    it "is html_safe" do
      expect(described_class[build_stubbed(:family)]).to be_html_safe
    end

    context "when taxon is valid" do
      let(:taxon) { build_stubbed :family }

      it "returns 'valid' if the status is valid" do
        expect(described_class[taxon]).to eq 'valid'
      end
    end

    context "when taxon is a homonym" do
      context "when taxon does not have a `homonym_replaced_by`" do
        let!(:taxon) { build_stubbed :family, :homonym }

        specify { expect(described_class[taxon]).to eq 'homonym' }
      end

      context "when taxon has a `homonym_replaced_by`" do
        let!(:homonym_replaced_by) { build_stubbed :family }
        let!(:taxon) { build_stubbed :family, :homonym, homonym_replaced_by: homonym_replaced_by }

        specify do
          expect(described_class[taxon]).to include %(homonym replaced by #{taxon_link homonym_replaced_by})
        end
      end
    end

    context "when taxon is unidentifiable" do
      let!(:taxon) { build_stubbed :family, :unidentifiable }

      specify { expect(described_class[taxon]).to eq "unidentifiable" }
    end

    context "when taxon is an unresolved homonym" do
      context "when there is no senior synonym" do
        let(:taxon) { build_stubbed :family, unresolved_homonym: true }

        specify { expect(described_class[taxon]).to eq 'unresolved junior homonym, valid' }
      end

      context "when there is a current valid taxon" do
        let(:senior) { build_stubbed :genus }
        let(:taxon) { build_stubbed :family, :synonym, unresolved_homonym: true, current_valid_taxon: senior }

        specify do
          expect(described_class[taxon]).
            to include %(unresolved junior homonym, junior synonym of current valid taxon #{taxon_link senior})
        end
      end
    end

    context "when taxon is a nomen nudum" do
      let!(:taxon) { build_stubbed :family, :unavailable, nomen_nudum: true }

      specify { expect(described_class[taxon]).to eq "<i>nomen nudum</i>, unavailable" }
    end

    context "when taxon is a synonym" do
      let!(:senior) { create :genus }
      let!(:taxon) { create :genus, :synonym, current_valid_taxon: senior }

      specify do
        expect(described_class[taxon]).
          to include %(junior synonym of current valid taxon #{taxon_link senior})
      end
    end

    context "when taxon is an unavailable misspelling" do
      let!(:current_valid_taxon) { build_stubbed :family }
      let!(:taxon) { build_stubbed :family, :unavailable_misspelling, current_valid_taxon: current_valid_taxon }

      specify do
        expect(described_class[taxon]).to include %(a misspelling of #{taxon_link current_valid_taxon})
      end
    end

    context 'when taxon is "unavailable uncategorized"' do
      let!(:current_valid_taxon) { build_stubbed :family }
      let!(:taxon) { build_stubbed :family, :unavailable_uncategorized, current_valid_taxon: current_valid_taxon }

      specify do
        expect(described_class[taxon]).to include %(see #{taxon_link current_valid_taxon})
      end
    end

    context "when taxon is `invalid?`" do
      let!(:taxon) { build_stubbed :family, :excluded_from_formicidae }

      specify { expect(described_class[taxon]).to eq "excluded from Formicidae" }
    end

    context "when taxon is incertae sedis" do
      let(:taxon) { build_stubbed :genus, incertae_sedis_in: 'family' }

      specify do
        expect(described_class[taxon]).to eq '<i>incertae sedis</i> in family, valid'
      end
    end
  end
end
