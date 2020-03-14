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

  describe ".single_word_name?" do
    specify do
      expect(described_class.single_word_name?('family')).to eq true
      expect(described_class.single_word_name?('subfamily')).to eq true
      expect(described_class.single_word_name?('tribe')).to eq true
      expect(described_class.single_word_name?('subtribe')).to eq true
      expect(described_class.single_word_name?('genus')).to eq true

      expect(described_class.single_word_name?('subgenus')).to eq false
      expect(described_class.single_word_name?('species')).to eq false
      expect(described_class.single_word_name?('subspecies')).to eq false
      expect(described_class.single_word_name?('infrasubspecies')).to eq false
    end
  end
end
