# frozen_string_literal: true

class Rank
  SORTED_TYPES = [
    FAMILY          = 'Family',
    SUBFAMILY       = 'Subfamily',
    TRIBE           = 'Tribe',
    SUBTRIBE        = 'Subtribe',
    GENUS           = 'Genus',
    SUBGENUS        = 'Subgenus',
    SPECIES         = 'Species',
    SUBSPECIES      = 'Subspecies',
    INFRASUBSPECIES = 'Infrasubspecies'
  ]
  TYPES = SORTED_TYPES

  ### Ranks in taxonomy, generally true.
  FAMILY_GROUP_NAMES = [FAMILY, SUBFAMILY, TRIBE, SUBTRIBE]
  GENUS_GROUP_NAMES = [GENUS, SUBGENUS]
  SPECIES_GROUP_NAMES = [SPECIES, SUBSPECIES, INFRASUBSPECIES]

  ABOVE_GENUS = FAMILY_GROUP_NAMES
  ABOVE_SPECIES = FAMILY_GROUP_NAMES + GENUS_GROUP_NAMES

  CAN_HAVE_TYPE_TAXON_TYPES = ABOVE_SPECIES
  CAN_BE_A_COMBINATION_TYPES = [GENUS, SUBGENUS, SPECIES, SUBSPECIES, INFRASUBSPECIES]
  ITALIC_TYPES = [GENUS, SUBGENUS, SPECIES, SUBSPECIES, INFRASUBSPECIES]

  # NOTE: Subgenera are uninomial, but not a "single word name" on AntCat.
  SINGLE_WORD_TYPES = [FAMILY, SUBFAMILY, TRIBE, SUBTRIBE, GENUS] # TODO: Duplicated in `Name::SINGLE_WORD_NAMES`.
  UNINOMIAL = ABOVE_SPECIES
  BINOMIAL = [SPECIES]
  TRINOMIAL = [SUBSPECIES]
  QUADRINOMIAL = [INFRASUBSPECIES]

  ### AntCat-specific config.
  # Allow any type while figuring this out. Required for showing-ish what we have now: `[FAMILY, SUBFAMILY, TRIBE,]`.
  TYPE_SPECIFIC_TAXON_HISTORY_ITEM_TYPES = TYPES
  CAN_HAVE_REFERENCE_SECTIONS_TYPES = FAMILY_GROUP_NAMES + GENUS_GROUP_NAMES

  SHOW_CREATE_COMBINATION_BUTTON_TYPES = [SPECIES]
  SHOW_CREATE_COMBINATION_HELP_BUTTON_TYPES = [SPECIES, SUBSPECIES]
  ALLOW_CREATE_OBSOLETE_COMBINATION_TYPES = [SPECIES]
  ALLOW_FORCE_CHANGE_PARENT_TYPES = [GENUS, SPECIES, SUBSPECIES]

  ### For `taxa.incertae_sedis_in`.
  # TODO: Probably upcase to match `taxa.type`.
  INCERTAE_SEDIS_IN_RANKS = [
    INCERTAE_SEDIS_IN_FAMILY = 'family',
    INCERTAE_SEDIS_IN_SUBFAMILY = 'subfamily',
    'tribe',
    'genus'
  ]

  class << self
    def italic? type
      type.in? ITALIC_TYPES
    end

    def single_word_name? type
      type.in? SINGLE_WORD_TYPES
    end

    # See https://en.wikipedia.org/wiki/Taxonomic_rank#Ranks_in_zoology
    def genus_group_name? type
      type.in? GENUS_GROUP_NAMES
    end
  end
end
