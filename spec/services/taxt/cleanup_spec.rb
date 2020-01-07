require 'rails_helper'

describe Taxt::Cleanup do
  describe '#call' do
    it 'strips double spaces and colons' do
      expect(described_class['Pi   zz : : a']).to eq 'Pi zz : a'
      expect(described_class[nil]).to eq nil
    end
  end
end
