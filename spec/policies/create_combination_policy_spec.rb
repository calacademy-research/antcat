require 'rails_helper'

describe CreateCombinationPolicy do
  subject(:policy) { described_class.new(taxon) }

  describe '#errors' do
    let(:taxon) { build_stubbed :family }

    it 'adds errors on initialization' do
      expect(policy.errors).to eq ["taxon is not a species"]
    end
  end

  describe '#allowed?' do
    context 'when allowed' do
      let(:taxon) { build_stubbed :species }

      specify { expect(policy.allowed?).to eq true }
    end

    context 'when not allowed' do
      let(:taxon) { build_stubbed :family }

      specify { expect(policy.allowed?).to eq false }
    end
  end
end
