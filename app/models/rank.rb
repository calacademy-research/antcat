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
  FAMILY_GROUP_NAME_TYPES = [FAMILY, SUBFAMILY, TRIBE, SUBTRIBE]
  GENUS_GROUP_NAME_TYPES = [GENUS, SUBGENUS]
  SPECIES_GROUP_NAME_TYPES = [SPECIES, SUBSPECIES, INFRASUBSPECIES]

  TYPES_ABOVE_GENUS = FAMILY_GROUP_NAME_TYPES
  TYPES_ABOVE_SPECIES = FAMILY_GROUP_NAME_TYPES + GENUS_GROUP_NAME_TYPES

  CAN_HAVE_TYPE_TAXON_TYPES = TYPES_ABOVE_SPECIES
  CAN_BE_A_COMBINATION_TYPES = [GENUS, SUBGENUS, SPECIES, SUBSPECIES, INFRASUBSPECIES]
  INCERTAE_SEDIS_IN_RANKS = [
    INCERTAE_SEDIS_IN_FAMILY = 'family',
    INCERTAE_SEDIS_IN_SUBFAMILY = 'subfamily',
    'tribe',
    'genus'
  ]
  ITALIC_TYPES = [GENUS, SUBGENUS, SPECIES, SUBSPECIES, INFRASUBSPECIES]
  SINGLE_WORD_TYPES = [FAMILY, SUBFAMILY, TRIBE, SUBTRIBE, GENUS] # TODO: Duplicated in `Name::SINGLE_WORD_NAMES`.

  ### AntCat-specific config.
  # Allow any type while figuring this out. Required for showing-ish what we have now: `[FAMILY, SUBFAMILY, TRIBE,]`.
  TYPE_SPECIFIC_TAXON_HISTORY_ITEM_TYPES = TYPES

  SHOW_CREATE_COMBINATION_BUTTON_TYPES = [SPECIES]
  SHOW_CREATE_COMBINATION_HELP_BUTTON_TYPES = [SPECIES, SUBSPECIES]
  ALLOW_CREATE_OBSOLETE_COMBINATION_TYPES = [SPECIES]
  ALLOW_FORCE_CHANGE_PARENT_TYPES = [GENUS, SPECIES, SUBSPECIES]

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
