require 'rails_helper'

describe Taxa::TaxonStatus do
  include TestLinksHelpers

  describe "#call" do
    it "is html_safe" do
      expect(described_class[build_stubbed(:family)]).to be_html_safe
    end

    describe 'main status' do
      context "when taxon status is 'valid'" do
        let(:taxon) { build_stubbed :family }

        specify { expect(described_class[taxon]).to eq 'valid' }
      end

      context "when taxon status is 'synonym'" do
        let!(:senior) { build_stubbed :genus }
        let!(:taxon) { build_stubbed :genus, :synonym, current_valid_taxon: senior }

        specify do
          expect(described_class[taxon]).
            to eq "junior synonym of current valid taxon #{taxon_link_with_author_citation(senior)}"
        end
      end

      context "when taxon status is 'homonym'" do
        let!(:homonym_replaced_by) { build_stubbed :family }
        let!(:taxon) { build_stubbed :family, :homonym, homonym_replaced_by: homonym_replaced_by }

        specify do
          expect(described_class[taxon]).to eq "homonym replaced by #{taxon_link_with_author_citation(homonym_replaced_by)}"
        end
      end

      context "when taxon status is 'unidentifiable'" do
        let!(:taxon) { build_stubbed :family, :unidentifiable }

        specify { expect(described_class[taxon]).to eq "unidentifiable" }
      end

      context "when taxon status is 'unavailable'" do
        let!(:taxon) { build_stubbed :family, :unavailable }

        specify { expect(described_class[taxon]).to eq "unavailable" }
      end

      context "when taxon status is 'excluded from Formicidae'" do
        let!(:taxon) { build_stubbed :family, :excluded_from_formicidae }

        specify { expect(described_class[taxon]).to eq "excluded from Formicidae" }
      end

      context "when taxon status is 'obsolete combination'" do
        let!(:current_valid_taxon) { build_stubbed :genus }
        let!(:taxon) { build_stubbed :species, :obsolete_combination, current_valid_taxon: current_valid_taxon }

        specify do
          expect(described_class[taxon]).
            to eq "an obsolete combination of #{taxon_link_with_author_citation(current_valid_taxon)}"
        end
      end

      context "when taxon status is 'unavailable misspelling'" do
        let!(:current_valid_taxon) { build_stubbed :family }
        let!(:taxon) { build_stubbed :family, :unavailable_misspelling, current_valid_taxon: current_valid_taxon }

        specify do
          expect(described_class[taxon]).to eq "a misspelling of #{taxon_link_with_author_citation(current_valid_taxon)}"
        end
      end

      context "when taxon status is 'unavailable uncategorized'" do
        let!(:current_valid_taxon) { build_stubbed :family }
        let!(:taxon) { build_stubbed :family, :unavailable_uncategorized, current_valid_taxon: current_valid_taxon }

        specify do
          expect(described_class[taxon]).to eq "see #{taxon_link_with_author_citation(current_valid_taxon)}"
        end
      end
    end

    describe 'prefixes and suffixes' do
      context "when taxon is incertae sedis" do
        let(:taxon) { build_stubbed :genus, :incertae_sedis_in_family }

        specify { expect(described_class[taxon]).to eq "<i>incertae sedis</i> in family, #{taxon.status}" }
      end

      context "when taxon is a nomen nudum" do
        let!(:taxon) { build_stubbed :family, :unavailable, nomen_nudum: true }

        specify { expect(described_class[taxon]).to eq "<i>nomen nudum</i>, #{taxon.status}" }
      end

      context "when taxon is an unresolved homonym" do
        context "when there is no current valid taxon" do
          let(:taxon) { build_stubbed :family, unresolved_homonym: true }

          specify { expect(described_class[taxon]).to eq "unresolved junior homonym, #{taxon.status}" }
        end

        context "when there is a current valid taxon" do
          let(:senior) { build_stubbed :genus }
          let(:taxon) { build_stubbed :family, :synonym, unresolved_homonym: true, current_valid_taxon: senior }

          specify do
            expect(described_class[taxon]).
              to eq "unresolved junior homonym, junior synonym of current valid taxon #{taxon_link_with_author_citation(senior)}"
          end
        end
      end

      context "when taxon is a collective group name" do
        let(:taxon) { build_stubbed :family, collective_group_name: true }

        specify { expect(described_class[taxon]).to eq "collective group name, #{taxon.status}" }
      end

      context "when taxon is an ichnotaxon" do
        let(:taxon) { build_stubbed :family, ichnotaxon: true }

        specify { expect(described_class[taxon]).to eq "#{taxon.status}, ichnotaxon" }
      end
    end
  end
end
