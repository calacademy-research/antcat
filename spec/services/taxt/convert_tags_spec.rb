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
        let!(:protonym_id) { taxon.protonym.id }

        specify do
          expect(described_class["{#{Taxt::TAX_TAG} #{taxon_id}pro}"]).to eq "{#{Taxt::PRO_TAG} #{protonym_id}}"
          expect(described_class["{#{Taxt::TAX_TAG} #{taxon_id}prott}"]).to eq "{#{Taxt::PROTT_TAG} #{protonym_id}}"
          expect(described_class["{#{Taxt::TAX_TAG} #{taxon_id}proac}"]).to eq "{#{Taxt::PROAC_TAG} #{protonym_id}}"
          expect(described_class["{#{Taxt::TAX_TAG} #{taxon_id}prottac}"]).to eq "{#{Taxt::PROTTAC_TAG} #{protonym_id}}"
        end

        specify do
          expect(described_class["{#{Taxt::TAXAC_TAG} #{taxon_id}pro}"]).to eq "{#{Taxt::PRO_TAG} #{protonym_id}}"
          expect(described_class["{#{Taxt::TAXAC_TAG} #{taxon_id}prott}"]).to eq "{#{Taxt::PROTT_TAG} #{protonym_id}}"
          expect(described_class["{#{Taxt::TAXAC_TAG} #{taxon_id}proac}"]).to eq "{#{Taxt::PROAC_TAG} #{protonym_id}}"
          expect(described_class["{#{Taxt::TAXAC_TAG} #{taxon_id}prottac}"]).to eq "{#{Taxt::PROTTAC_TAG} #{protonym_id}}"
        end
      end

      context "when taxon does not exists" do
        specify { expect(described_class["{#{Taxt::TAX_TAG} 00pro}"]).to eq "{#{Taxt::TAX_TAG} 00pro}" }
        specify { expect(described_class["{#{Taxt::TAXAC_TAG} 00pro}"]).to eq "{#{Taxt::TAXAC_TAG} 00pro}" }
      end
    end
  end
end
