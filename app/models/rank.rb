# frozen_string_literal: true

# TODO: Improve rank vs. type.

class Rank
  TYPES = %w[Family Subfamily Tribe Subtribe Genus Subgenus Species Subspecies Infrasubspecies]
  TYPES_ABOVE_GENUS = %w[Family Subfamily Subtribe Tribe]
  TYPES_ABOVE_SPECIES = %w[Family Subfamily Tribe Subtribe Genus Subgenus]
  CAN_HAVE_TYPE_TAXON_TYPES = TYPES_ABOVE_SPECIES
  CAN_BE_A_COMBINATION_TYPES = %w[Genus Subgenus Species Subspecies Infrasubspecies]
  INCERTAE_SEDIS_IN_RANKS = [
    INCERTAE_SEDIS_IN_FAMILY = 'family',
    INCERTAE_SEDIS_IN_SUBFAMILY = 'subfamily',
    'tribe',
    'genus'
  ]
  ITALIC_RANKS = %w[genus subgenus species subspecies infrasubspecies]
  # TODO: Duplicated in `Name::SINGLE_WORD_NAMES`.
  SINGLE_WORD_RANKS = %w[family subfamily tribe subtribe genus]
  GENUS_GROUP_NAMES_RANKS = %w[genus subgenus]

  class << self
    def italic? rank
      rank.in? ITALIC_RANKS
    end

    def single_word_name? rank
      rank.in? SINGLE_WORD_RANKS
    end

    # See https://en.wikipedia.org/wiki/Taxonomic_rank#Ranks_in_zoology
    def genus_group_name? rank
      rank.in? GENUS_GROUP_NAMES_RANKS
    end
  end
end
