# frozen_string_literal: true

class Rank
  TYPES = %w[Family Subfamily Tribe Subtribe Genus Subgenus Species Subspecies Infrasubspecies]

  ### Ranks in taxonomy, generally true.
  TYPES_ABOVE_GENUS = %w[Family Subfamily Tribe Subtribe]
  TYPES_ABOVE_SPECIES = %w[Family Subfamily Tribe Subtribe Genus Subgenus]

  GENUS_GROUP_NAME_TYPES = %w[Genus Subgenus]
  SPECIES_GROUP_NAME_TYPES = %w[Species Subspecies Infrasubspecies]

  CAN_HAVE_TYPE_TAXON_TYPES = TYPES_ABOVE_SPECIES
  CAN_BE_A_COMBINATION_TYPES = %w[Genus Subgenus Species Subspecies Infrasubspecies]
  INCERTAE_SEDIS_IN_RANKS = [
    INCERTAE_SEDIS_IN_FAMILY = 'family',
    INCERTAE_SEDIS_IN_SUBFAMILY = 'subfamily',
    'tribe',
    'genus'
  ]
  ITALIC_TYPES = %w[Genus Subgenus Species Subspecies Infrasubspecies]
  SINGLE_WORD_TYPES = %w[Family Subfamily Tribe Subtribe Genus] # TODO: Duplicated in `Name::SINGLE_WORD_NAMES`.

  ### AntCat-specific config.
  # Allow any type while figuring this out. Required for showing-ish what we have now: `%w[Family Subfamily Tribe]`.
  TYPE_SPECIFIC_TAXON_HISTORY_ITEM_TYPES = TYPES

  SHOW_CREATE_COMBINATION_BUTTON_TYPES = %w[Species]
  SHOW_CREATE_COMBINATION_HELP_BUTTON_TYPES = %w[Species Subspecies]
  ALLOW_CREATE_OBSOLETE_COMBINATION_TYPES = %w[Species]
  ALLOW_FORCE_CHANGE_PARENT_TYPES = %w[Genus Species Subspecies]

  class << self
    def italic? type
      type.in? ITALIC_TYPES
    end

    def single_word_name? type
      type.in? SINGLE_WORD_TYPES
    end

    # See https://en.wikipedia.org/wiki/Taxonomic_rank#Ranks_in_zoology
    def genus_group_name? type
      type.in? GENUS_GROUP_NAME_TYPES
    end
  end
end
