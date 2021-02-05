# frozen_string_literal: true

class Rank
  TYPES = [
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

  ### Ranks in taxonomy, generally true.
  RANKS_BY_GROUP = {
    FAMILY => FAMILY_GROUP_NAMES = [FAMILY, SUBFAMILY, TRIBE, SUBTRIBE],
    GENUS => GENUS_GROUP_NAMES = [GENUS, SUBGENUS],
    SPECIES => SPECIES_GROUP_NAMES = [SPECIES, SUBSPECIES, INFRASUBSPECIES]
  }
  GROUP_RANKS = RANKS_BY_GROUP.each_with_object({}) { |(k, v), memo| v.each { |vv| memo[vv] = k } }

  ABOVE_GENUS = FAMILY_GROUP_NAMES
  GENUS_AND_BELOW = GENUS_GROUP_NAMES + SPECIES_GROUP_NAMES
  ABOVE_SPECIES = FAMILY_GROUP_NAMES + GENUS_GROUP_NAMES

  CAN_HAVE_TYPE_TAXON_TYPES = ABOVE_SPECIES
  CAN_BE_A_COMBINATION_TYPES = [GENUS, SUBGENUS, SPECIES, SUBSPECIES, INFRASUBSPECIES]
  ITALIC_TYPES = GENUS_AND_BELOW

  UNINOMIAL = ABOVE_SPECIES
  BINOMIAL = [SPECIES]
  TRINOMIAL = [SUBSPECIES]
  QUADRINOMIAL = [INFRASUBSPECIES]

  ### For `taxa.incertae_sedis_in`.
  INCERTAE_SEDIS_IN_TYPES = [FAMILY, SUBFAMILY, TRIBE, GENUS]

  module AntCatSpecific
    # NOTE: Subgenera are uninomial, but not a "single word name" on AntCat.
    SINGLE_WORD_TYPES = [FAMILY, SUBFAMILY, TRIBE, SUBTRIBE, GENUS] # TODO: Duplicated in `Name::SINGLE_WORD_NAMES`.

    # Allow any type while figuring this out. Required for showing-ish what we have now: `[FAMILY, SUBFAMILY, TRIBE]`.
    TYPE_SPECIFIC_HISTORY_ITEM_TYPES = TYPES
    CAN_HAVE_REFERENCE_SECTIONS_TYPES = FAMILY_GROUP_NAMES + GENUS_GROUP_NAMES

    SHOW_CREATE_COMBINATION_BUTTON_TYPES = [SPECIES]
    ALLOW_CREATE_OBSOLETE_COMBINATION_TYPES = [SPECIES]
    ALLOW_FORCE_CHANGE_PARENT_TYPES = [GENUS, SPECIES, SUBSPECIES]
  end

  class << self
    def italic? type
      type.in? ITALIC_TYPES
    end

    def single_word_name? type
      type.in? AntCatSpecific::SINGLE_WORD_TYPES
    end

    def group_rank type
      GROUP_RANKS[type]
    end

    # See https://en.wikipedia.org/wiki/Taxonomic_rank#Ranks_in_zoology
    def genus_group_name? type
      type.in? GENUS_GROUP_NAMES
    end

    def species_group_name? type
      type.in? SPECIES_GROUP_NAMES
    end

    # TODO: Rename to something like `number_of_countable_name_parts` to distinguish it from names with connecting terms.
    def number_of_name_parts type
      case type
      when *UNINOMIAL    then 1
      when *BINOMIAL     then 2
      when *TRINOMIAL    then 3
      when *QUADRINOMIAL then 4
      else 0
      end
    end

    def sort_ranks ranks
      ranks.sort_by { |rank| TYPES.index(rank) }
    end

    def sort_ranks_hash hsh
      hsh.sort_by { |(rank, _)| rank ? TYPES.index(rank) : 0 }.to_h
    end
  end
end
