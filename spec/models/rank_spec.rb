# frozen_string_literal: true

require 'rails_helper'

describe Rank do
  describe 'constants' do
    it "covers all types in '*_GROUP_TYPES'" do
      types = described_class::FAMILY_GROUP_NAMES + described_class::GENUS_GROUP_NAMES + described_class::SPECIES_GROUP_NAMES
      expect(types).to eq described_class::SORTED_TYPES
    end

    it "covers all types in 'ABOVE_SPECIES' and 'SPECIES_GROUP_NAMES'" do
      expect(described_class::ABOVE_SPECIES + described_class::SPECIES_GROUP_NAMES).to eq described_class::TYPES
    end

    described_class.constants.select { |const_sym| const_sym.to_s['TYPE'] }.each do |const_sym|
      it "keeps types in `#{const_sym}` sorted with higher ranks first`" do
        types = described_class.const_get(const_sym)
        sorted_types = types.sort_by { |type| described_class::TYPES.index(type) }

        expect(types).to eq sorted_types
      end
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
