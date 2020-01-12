require 'rails_helper'

describe Taxt::Cleanup do
  describe '#call' do
    context 'when string is nil' do
      specify { expect(described_class[nil]).to eq nil }
    end

    it 'removes multiple consecutive spaces' do
      expect(described_class['p    izza']).to eq 'p izza'
    end

    it 'removes leading and trailing whitespace' do
      expect(described_class['   pizza ']).to eq 'pizza'
    end

    it 'removes colons separated by spaces' do
      expect(described_class[': : pizza']).to eq ': pizza'
    end

    it 'moves spaces before colons to after the colon' do
      expect(described_class['p :izza']).to eq 'p: izza'
    end

    it 'adds spaces after colons' do
      expect(described_class[':pizza']).to eq ': pizza'
    end

    it 'can beat the final boss and his minions' do
      expect(described_class['  Pi   zz : : a pescatore :1:']).to eq 'Pi zz: a pescatore: 1:'
    end
  end
end
