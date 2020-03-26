# frozen_string_literal: true

require 'rails_helper'

describe TaxonBrowser::LinksToExtraTabs do
  describe '#call' do
    context 'when taxon is a family' do
      context 'when family has incertae sedis genera' do
        let!(:taxon) { create :family }

        before { create :genus, :incertae_sedis_in_family }

        specify do
          expect(described_class[taxon]).to eq(
            [
              { label: "All genera", display: TaxonBrowser::Tab::ALL_GENERA_IN_FAMILY },
              { label: "Incertae sedis", display: TaxonBrowser::Tab::INCERTAE_SEDIS_IN_FAMILY }
            ]
          )
        end
      end
    end

    context 'when taxon is a subfamily' do
      context 'when subfamily has incertae sedis genera' do
        let!(:taxon) { create :subfamily }

        before { create :genus, :incertae_sedis_in_subfamily, subfamily: taxon }

        specify do
          expect(described_class[taxon]).to eq(
            [
              { label: "All genera", display: TaxonBrowser::Tab::ALL_GENERA_IN_SUBFAMILY },
              { label: "Without tribe", display: TaxonBrowser::Tab::GENERA_WITHOUT_TRIBE },
              { label: "Incertae sedis", display: TaxonBrowser::Tab::INCERTAE_SEDIS_IN_SUBFAMILY }
            ]
          )
        end
      end
    end

    context 'when taxon is a genus' do
      let!(:taxon) { create :genus }

      context 'when genus has no subgenera' do
        specify do
          expect(described_class[taxon]).to eq(
            [
              { label: "All taxa", display: TaxonBrowser::Tab::ALL_TAXA_IN_GENUS }
            ]
          )
        end
      end

      context 'when genus has subgenera' do
        before { create :subgenus, genus: taxon }

        specify do
          expect(described_class[taxon]).to eq(
            [
              { label: "All taxa", display: TaxonBrowser::Tab::ALL_TAXA_IN_GENUS },
              { label: "Subgenera", display: TaxonBrowser::Tab::SUBGENERA_IN_GENUS },
              { label: "Without subgenus", display: TaxonBrowser::Tab::SPECIES_WITHOUT_SUBGENUS }
            ]
          )
        end
      end
    end

    context 'when taxon is a tribe' do
      context 'when tribe has subtribes' do
        let!(:taxon) { create :tribe }

        before { create :subtribe, tribe: taxon }

        specify do
          expect(described_class[taxon]).to eq(
            [
              { label: "Subtribes", display: TaxonBrowser::Tab::SUBTRIBES_IN_TRIBE }
            ]
          )
        end
      end
    end
  end
end
