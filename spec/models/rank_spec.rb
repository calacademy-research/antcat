# frozen_string_literal: true

require 'rails_helper'

describe Rank do
  describe ".italic?" do
    specify do
      expect(described_class.italic?(described_class::FAMILY)).to eq false
      expect(described_class.italic?(described_class::SUBFAMILY)).to eq false
      expect(described_class.italic?(described_class::TRIBE)).to eq false
      expect(described_class.italic?(described_class::SUBTRIBE)).to eq false

      expect(described_class.italic?(described_class::GENUS)).to eq true
      expect(described_class.italic?(described_class::SUBGENUS)).to eq true
      expect(described_class.italic?(described_class::SPECIES)).to eq true
      expect(described_class.italic?(described_class::SUBSPECIES)).to eq true
      expect(described_class.italic?(described_class::INFRASUBSPECIES)).to eq true
    end
  end

  describe ".single_word_name?" do
    specify do
      expect(described_class.single_word_name?(described_class::FAMILY)).to eq true
      expect(described_class.single_word_name?(described_class::SUBFAMILY)).to eq true
      expect(described_class.single_word_name?(described_class::TRIBE)).to eq true
      expect(described_class.single_word_name?(described_class::SUBTRIBE)).to eq true
      expect(described_class.single_word_name?(described_class::GENUS)).to eq true

      expect(described_class.single_word_name?(described_class::SUBGENUS)).to eq false
      expect(described_class.single_word_name?(described_class::SPECIES)).to eq false
      expect(described_class.single_word_name?(described_class::SUBSPECIES)).to eq false
      expect(described_class.single_word_name?(described_class::INFRASUBSPECIES)).to eq false
    end
  end

  describe ".genus_group_name?" do
    specify do
      expect(described_class.genus_group_name?(described_class::FAMILY)).to eq false
      expect(described_class.genus_group_name?(described_class::SUBFAMILY)).to eq false
      expect(described_class.genus_group_name?(described_class::TRIBE)).to eq false
      expect(described_class.genus_group_name?(described_class::SUBTRIBE)).to eq false

      expect(described_class.genus_group_name?(described_class::GENUS)).to eq true
      expect(described_class.genus_group_name?(described_class::SUBGENUS)).to eq true

      expect(described_class.genus_group_name?(described_class::SPECIES)).to eq false
      expect(described_class.genus_group_name?(described_class::SUBSPECIES)).to eq false
      expect(described_class.genus_group_name?(described_class::INFRASUBSPECIES)).to eq false
    end
  end

  describe ".species_group_name?" do
    specify do
      expect(described_class.species_group_name?(described_class::FAMILY)).to eq false
      expect(described_class.species_group_name?(described_class::SUBFAMILY)).to eq false
      expect(described_class.species_group_name?(described_class::TRIBE)).to eq false
      expect(described_class.species_group_name?(described_class::SUBTRIBE)).to eq false

      expect(described_class.species_group_name?(described_class::GENUS)).to eq false
      expect(described_class.species_group_name?(described_class::SUBGENUS)).to eq false

      expect(described_class.species_group_name?(described_class::SPECIES)).to eq true
      expect(described_class.species_group_name?(described_class::SUBSPECIES)).to eq true
      expect(described_class.species_group_name?(described_class::INFRASUBSPECIES)).to eq true
    end
  end

  describe ".number_of_name_parts" do
    specify do
      expect(described_class.number_of_name_parts(described_class::FAMILY)).to eq 1
      expect(described_class.number_of_name_parts(described_class::SUBFAMILY)).to eq 1
      expect(described_class.number_of_name_parts(described_class::TRIBE)).to eq 1
      expect(described_class.number_of_name_parts(described_class::SUBTRIBE)).to eq 1

      expect(described_class.number_of_name_parts(described_class::GENUS)).to eq 1
      expect(described_class.number_of_name_parts(described_class::SUBGENUS)).to eq 1

      expect(described_class.number_of_name_parts(described_class::SPECIES)).to eq 2
      expect(described_class.number_of_name_parts(described_class::SUBSPECIES)).to eq 3
      expect(described_class.number_of_name_parts(described_class::INFRASUBSPECIES)).to eq 4
    end
  end

  describe ".sort_ranks" do
    specify do
      unsorted_ranks = [described_class::SPECIES, described_class::FAMILY]

      expect(described_class.sort_ranks(unsorted_ranks)).to eq [described_class::FAMILY, described_class::SPECIES]
    end
  end

  describe ".sort_ranks_hash" do
    specify do
      unsorted_ranks = {
        described_class::SPECIES => 'a',
        described_class::FAMILY => 'a',
        nil => 'a'
      }

      expect(described_class.sort_ranks_hash(unsorted_ranks)).to eq(
        nil => 'a',
        described_class::FAMILY => 'a',
        described_class::SPECIES => 'a'
      )
    end
  end
end
