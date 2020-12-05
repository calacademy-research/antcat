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
end
