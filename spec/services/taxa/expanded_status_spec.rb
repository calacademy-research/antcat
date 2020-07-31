# frozen_string_literal: true

require 'rails_helper'

describe Taxa::ExpandedStatus do
  include TestLinksHelpers

  describe "#call" do
    specify { expect(described_class[build_stubbed(:any_taxon)].html_safe?).to eq true }

    describe 'main status' do
      context "when taxon status is 'valid'" do
        let(:taxon) { build_stubbed :any_taxon }

        specify { expect(described_class[taxon]).to eq 'valid' }
      end

      context "when taxon status is 'synonym'" do
        let!(:senior) { create :genus }
        let!(:taxon) { build_stubbed :genus, :synonym, current_taxon: senior }

        specify do
          expect(described_class[taxon]).
            to eq "junior synonym of current valid taxon #{taxon_link_with_author_citation(senior)}"
        end
      end

      context "when taxon status is 'homonym'" do
        let!(:taxon) { build_stubbed :any_taxon, :homonym }

        specify do
          expect(described_class[taxon]).
            to eq "homonym replaced by #{taxon_link_with_author_citation(taxon.homonym_replaced_by)}"
        end
      end

      context "when taxon status is 'unidentifiable'" do
        let!(:taxon) { build_stubbed :any_taxon, :unidentifiable }

        specify { expect(described_class[taxon]).to eq "unidentifiable" }
      end

      context "when taxon status is 'unavailable'" do
        let!(:taxon) { build_stubbed :any_taxon, :unavailable }

        specify { expect(described_class[taxon]).to eq "unavailable" }
      end

      context "when taxon status is 'excluded from Formicidae'" do
        let!(:taxon) { build_stubbed :any_taxon, :excluded_from_formicidae }

        specify { expect(described_class[taxon]).to eq "excluded from Formicidae" }
      end

      context "when taxon status is 'obsolete combination'" do
        let!(:current_taxon) { create :genus }
        let!(:taxon) { build_stubbed :species, :obsolete_combination, current_taxon: current_taxon }

        specify do
          expect(described_class[taxon]).
            to eq "an obsolete combination of #{taxon_link_with_author_citation(current_taxon)}"
        end
      end

      context "when taxon status is 'unavailable misspelling'" do
        let!(:current_taxon) { create :any_taxon }
        let!(:taxon) { build_stubbed :any_taxon, :unavailable_misspelling, current_taxon: current_taxon }

        specify do
          expect(described_class[taxon]).to eq "a misspelling of #{taxon_link_with_author_citation(current_taxon)}"
        end
      end
    end

    describe 'prefixes and suffixes' do
      context "when taxon is incertae sedis" do
        let(:taxon) { build_stubbed :genus, :incertae_sedis_in_family }

        specify { expect(described_class[taxon]).to eq "<i>incertae sedis</i> in family, #{taxon.status}" }
      end

      context "when taxon is a nomen nudum" do
        let(:protonym) { build_stubbed :protonym, :nomen_nudum }
        let!(:taxon) { build_stubbed :any_taxon, :unavailable, protonym: protonym }

        specify { expect(described_class[taxon]).to eq "<i>nomen nudum</i>, #{taxon.status}" }
      end

      context "when taxon is an unresolved homonym" do
        context "when there is no current taxon" do
          let(:taxon) { build_stubbed :any_taxon, :unresolved_homonym }

          specify { expect(described_class[taxon]).to eq "unresolved junior homonym, #{taxon.status}" }
        end

        context "when there is a current taxon" do
          let(:senior) { create :any_taxon }
          let(:taxon) { build_stubbed :any_taxon, :synonym, :unresolved_homonym, current_taxon: senior }

          specify do
            expect(described_class[taxon]).
              to eq "unresolved junior homonym, junior synonym of current valid taxon #{taxon_link_with_author_citation(senior)}"
          end
        end
      end

      context "when taxon is a collective group name" do
        let(:taxon) { build_stubbed :any_taxon, collective_group_name: true }

        specify { expect(described_class[taxon]).to eq "collective group name, #{taxon.status}" }
      end

      context "when taxon is an ichnotaxon" do
        let(:taxon) { build_stubbed :any_taxon, ichnotaxon: true }

        specify { expect(described_class[taxon]).to eq "#{taxon.status}, ichnotaxon" }
      end
    end
  end
end
