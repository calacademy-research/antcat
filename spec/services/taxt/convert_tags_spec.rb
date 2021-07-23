# frozen_string_literal: true

require 'rails_helper'

describe Taxt::ConvertTags do
  describe '#call' do
    context 'when string is nil' do
      specify { expect(described_class[nil]).to eq nil }
    end

    describe 'converting taxon tags to protonym tags' do
      context "when taxon exists" do
        let!(:taxon) { create :family }
        let!(:taxon_id) { taxon.id }
        let!(:protonym) { taxon.protonym }

        specify do
          expect(described_class[Taxt.tax("#{taxon_id}pro")]).to eq Taxt.pro(protonym.id)
          expect(described_class[Taxt.tax("#{taxon_id}prott")]).to eq Taxt.prott(protonym.id)
          expect(described_class[Taxt.tax("#{taxon_id}proac")]).to eq Taxt.proac(protonym.id)
          expect(described_class[Taxt.tax("#{taxon_id}prottac")]).to eq Taxt.prottac(protonym.id)
        end

        specify do
          expect(described_class[Taxt.taxac("#{taxon_id}pro")]).to eq Taxt.pro(protonym.id)
          expect(described_class[Taxt.taxac("#{taxon_id}prott")]).to eq Taxt.prott(protonym.id)
          expect(described_class[Taxt.taxac("#{taxon_id}proac")]).to eq Taxt.proac(protonym.id)
          expect(described_class[Taxt.taxac("#{taxon_id}prottac")]).to eq Taxt.prottac(protonym.id)
        end
      end

      context "when taxon does not exists" do
        specify { expect(described_class[Taxt.tax("00pro")]).to eq "{#{Taxt::TAX_TAG} 00pro}" }
        specify { expect(described_class[Taxt.taxac("00pro")]).to eq "{#{Taxt::TAXAC_TAG} 00pro}" }
      end
    end

    describe 'converting protonym tags to taxon tags' do
      context "when protonym and terminal taxon exists" do
        let!(:protonym) { create :protonym, :family_group }
        let!(:protonym_id) { protonym.id }
        let!(:taxon) { create :family, protonym: protonym }
        let!(:terminal_taxon) { protonym.terminal_taxon }

        specify do
          expect(described_class[Taxt.pro("#{protonym_id}tax")]).to eq Taxt.tax(terminal_taxon.id)
          expect(described_class[Taxt.pro("#{protonym_id}taxac")]).to eq Taxt.taxac(terminal_taxon.id)
        end

        specify do
          expect(described_class[Taxt.prott("#{protonym_id}tax")]).to eq Taxt.tax(terminal_taxon.id)
          expect(described_class[Taxt.prott("#{protonym_id}taxac")]).to eq Taxt.taxac(terminal_taxon.id)
        end

        specify do
          expect(described_class[Taxt.proac("#{protonym_id}tax")]).to eq Taxt.tax(terminal_taxon.id)
          expect(described_class[Taxt.proac("#{protonym_id}taxac")]).to eq Taxt.taxac(terminal_taxon.id)
        end

        specify do
          expect(described_class[Taxt.prottac("#{protonym_id}tax")]).to eq Taxt.tax(terminal_taxon.id)
          expect(described_class[Taxt.prottac("#{protonym_id}taxac")]).to eq Taxt.taxac(terminal_taxon.id)
        end
      end

      context "when protonym does not have a terminal taxon" do
        let!(:protonym) { create :protonym }
        let!(:protonym_id) { protonym.id }

        specify do
          expect(described_class[Taxt.pro("#{protonym_id}tax")]).
            to eq "{#{Taxt::PRO_TAG} #{protonym_id}tax}"
        end
      end

      context "when protonym does not exists" do
        specify { expect(described_class[Taxt.pro("00tax")]).to eq "{#{Taxt::PRO_TAG} 00tax}" }
      end
    end
  end
end
