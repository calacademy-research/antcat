# frozen_string_literal: true

require 'rails_helper'

describe Rank do
  describe 'constants' do
    it "covers all types in 'TYPES_ABOVE_SPECIES' and 'SPECIES_GROUP_NAME_TYPES'" do
      expect(described_class::TYPES_ABOVE_SPECIES + described_class::SPECIES_GROUP_NAME_TYPES).to eq described_class::TYPES
    end
  end

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

  describe ".genus_group_name?" do
    specify do
      expect(described_class.genus_group_name?('Family')).to eq false
      expect(described_class.genus_group_name?('Subfamily')).to eq false
      expect(described_class.genus_group_name?('Tribe')).to eq false
      expect(described_class.genus_group_name?('Subtribe')).to eq false

      expect(described_class.genus_group_name?('Genus')).to eq true
      expect(described_class.genus_group_name?('Subgenus')).to eq true

      expect(described_class.genus_group_name?('Species')).to eq false
      expect(described_class.genus_group_name?('Subspecies')).to eq false
      expect(described_class.genus_group_name?('Infrasubspecies')).to eq false
    end
  end
end
