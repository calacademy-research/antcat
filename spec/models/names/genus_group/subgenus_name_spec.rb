require 'rails_helper'

describe SubgenusName do
  describe '#name=' do
    specify do
      name = described_class.new(name: 'Lasius (Austrolasius)')

      expect(name.name).to eq 'Lasius (Austrolasius)'
      expect(name.epithet).to eq 'Austrolasius'
      expect(name.epithets).to eq nil
    end
  end
end
