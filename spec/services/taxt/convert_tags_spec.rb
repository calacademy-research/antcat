# frozen_string_literal: true

require 'rails_helper'

describe Taxt::ConvertTags do
  describe '#call' do
    context 'when string is nil' do
      specify { expect(described_class[nil]).to eq nil }
    end

    describe 'converting `tax` tags to other tags' do
      context "when taxon exists" do
        let(:taxon) { create :family }
        let(:taxon_id) { taxon.id }
        let(:protonym_id) { taxon.protonym.id }

        specify { expect(described_class["{tax #{taxon_id}p}"]).to eq "{pro #{protonym_id}}" }
        specify { expect(described_class["{tax #{taxon_id}pro}"]).to eq "{pro #{protonym_id}}" }
        specify { expect(described_class["{tax #{taxon_id}prott}"]).to eq "{prott #{protonym_id}}" }
        specify { expect(described_class["{tax #{taxon_id}proac}"]).to eq "{proac #{protonym_id}}" }
      end

      context "when taxon does not exists" do
        specify { expect(described_class["{tax 00pro}"]).to eq "{tax 00pro}" }
      end
    end
  end
end
