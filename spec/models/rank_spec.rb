# frozen_string_literal: true

require 'rails_helper'

describe Rank do
  describe 'constants' do
    specify "'*_GROUP_TYPES'" do
      it_covers_all_types_without_overlaps :FAMILY_GROUP_NAMES, :GENUS_GROUP_NAMES, :SPECIES_GROUP_NAMES
    end

    describe "'ABOVE_*' and 'BELOW_*'" do
      specify 'ABOVE_GENUS' do
        it_covers_all_types_without_overlaps :ABOVE_GENUS, :GENUS_AND_BELOW
      end

      specify 'GENUS_AND_BELOW' do
        it_covers_all_types_without_overlaps :FAMILY_GROUP_NAMES, :GENUS_AND_BELOW
      end

      specify 'ABOVE_SPECIES' do
        it_covers_all_types_without_overlaps :ABOVE_SPECIES, :SPECIES_GROUP_NAMES
      end
    end

    specify "'UNI-BI-TRI-QUADRI-NOMIAL'" do
      it_covers_all_types_without_overlaps :UNINOMIAL, :BINOMIAL, :TRINOMIAL, :QUADRINOMIAL
    end

    described_class.constants.select { |const_sym| const_sym.to_s['TYPE'] }.each do |const_sym|
      it "keeps types in `#{const_sym}` sorted with higher ranks first`" do
        types = described_class.const_get(const_sym)
        sorted_types = types.sort_by { |type| described_class::TYPES.index(type) }

        expect(types).to eq sorted_types
      end
    end

    def it_covers_all_types_without_overlaps *rank_collections
      type_constants = rank_collections.map { |const_sym| described_class.const_get(const_sym) }
      expect(type_constants.flatten).to eq described_class::TYPES
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
