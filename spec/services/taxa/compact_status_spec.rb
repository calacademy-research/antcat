# frozen_string_literal: true

require 'rails_helper'

describe Taxa::CompactStatus do
  include TestLinksHelpers

  describe "#call" do
    specify { expect(described_class[build_stubbed(:family)].html_safe?).to eq true }

    describe 'main status' do
      context "when taxon status is 'valid'" do
        let(:taxon) { build_stubbed :family }

        specify { expect(described_class[taxon]).to eq '' }
      end

      context "when taxon status is 'synonym'" do
        let!(:senior) { build_stubbed :genus }
        let!(:taxon) { build_stubbed :genus, :synonym, current_valid_taxon: senior }

        specify do
          expect(described_class[taxon]).
            to eq "junior synonym of #{taxon_link(senior)}"
        end
      end

      context "when taxon status is 'homonym'" do
        let!(:taxon) { build_stubbed :family, :homonym }

        specify do
          expect(described_class[taxon]).to eq "homonym replaced by #{taxon_link(taxon.homonym_replaced_by)}"
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
            to eq "obsolete combination of #{taxon_link(current_valid_taxon)}"
        end
      end

      context "when taxon status is 'unavailable misspelling'" do
        let!(:current_valid_taxon) { build_stubbed :family }
        let!(:taxon) { build_stubbed :family, :unavailable_misspelling, current_valid_taxon: current_valid_taxon }

        specify do
          expect(described_class[taxon]).to eq "misspelling of #{taxon_link(current_valid_taxon)}"
        end
      end

      context "when taxon status is 'unavailable uncategorized'" do
        let!(:current_valid_taxon) { build_stubbed :family }
        let!(:taxon) { build_stubbed :family, :unavailable_uncategorized, current_valid_taxon: current_valid_taxon }

        specify do
          expect(described_class[taxon]).to eq "see #{taxon_link(current_valid_taxon)}"
        end
      end
    end

    describe 'prefixes and suffixes' do
      context "when taxon is incertae sedis" do
        let(:taxon) { build_stubbed :genus, :incertae_sedis_in_family }

        specify { expect(described_class[taxon]).to eq "" }
      end

      context "when taxon is a nomen nudum" do
        let!(:taxon) { build_stubbed :family, :unavailable, nomen_nudum: true }

        specify { expect(described_class[taxon]).to eq "<i>nomen nudum</i>" }
      end

      context "when taxon is an unresolved homonym" do
        context "when there is no current valid taxon" do
          let(:taxon) { build_stubbed :family, unresolved_homonym: true }

          specify { expect(described_class[taxon]).to eq "unresolved junior homonym" }
        end

        context "when there is a current valid taxon" do
          let(:senior) { build_stubbed :genus }
          let(:taxon) { build_stubbed :family, :synonym, unresolved_homonym: true, current_valid_taxon: senior }

          specify do
            expect(described_class[taxon]).
              to eq "unresolved junior homonym, junior synonym of #{taxon_link(senior)}"
          end
        end
      end

      context "when taxon is a collective group name" do
        let(:taxon) { build_stubbed :family, collective_group_name: true }

        specify { expect(described_class[taxon]).to eq "" }
      end

      context "when taxon is an ichnotaxon" do
        let(:taxon) { build_stubbed :family, ichnotaxon: true }

        specify { expect(described_class[taxon]).to eq "" }
      end
    end
  end
end
