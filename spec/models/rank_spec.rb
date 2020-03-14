require 'rails_helper'

describe Rank do
  describe ".italic?" do
    specify do
      expect(described_class.italic?('family')).to eq false
      expect(described_class.italic?('subfamily')).to eq false
      expect(described_class.italic?('tribe')).to eq false
      expect(described_class.italic?('subtribe')).to eq false

      expect(described_class.italic?('genus')).to eq true
      expect(described_class.italic?('subgenus')).to eq true
      expect(described_class.italic?('species')).to eq true
      expect(described_class.italic?('subspecies')).to eq true
      expect(described_class.italic?('infrasubspecies')).to eq true
    end
  end
end
