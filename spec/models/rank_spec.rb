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
      expect(described_class.italic?('Family')).to eq false
      expect(described_class.italic?('Subfamily')).to eq false
      expect(described_class.italic?('Tribe')).to eq false
      expect(described_class.italic?('Subtribe')).to eq false

      expect(described_class.italic?('Genus')).to eq true
      expect(described_class.italic?('Subgenus')).to eq true
      expect(described_class.italic?('Species')).to eq true
      expect(described_class.italic?('Subspecies')).to eq true
      expect(described_class.italic?('Infrasubspecies')).to eq true
    end
  end

  describe ".single_word_name?" do
    specify do
      expect(described_class.single_word_name?('Family')).to eq true
      expect(described_class.single_word_name?('Subfamily')).to eq true
      expect(described_class.single_word_name?('Tribe')).to eq true
      expect(described_class.single_word_name?('Subtribe')).to eq true
      expect(described_class.single_word_name?('Genus')).to eq true

      expect(described_class.single_word_name?('Subgenus')).to eq false
      expect(described_class.single_word_name?('Species')).to eq false
      expect(described_class.single_word_name?('Subspecies')).to eq false
      expect(described_class.single_word_name?('Infrasubspecies')).to eq false
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
