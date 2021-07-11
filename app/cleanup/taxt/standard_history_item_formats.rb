# frozen_string_literal: true

# See also https://antcat.org/wiki/11
# For Ctrl-c:
#   Taxt::StandardHistoryItemFormats::PAGINATION_MANY
#   Taxt::StandardHistoryItemFormats::PAGINATION_MANY_EXACT

module Taxt
  class StandardHistoryItemFormats
    PROTT = "{#{Taxt::PROTT_TAG} [0-9]+}"
    TAX = "{#{Taxt::TAX_TAG} [0-9]+}"
    TAXAC = "{#{Taxt::TAXAC_TAG} [0-9]+}"
    TAX_ISH = "{(#{Taxt::TAXON_TAGS.join('|')}) [0-9]+}"
    PRO_ISH = "{(#{Taxt::PROTONYM_TAGS.join('|')}) [0-9]+}"
    TAX_OR_PRO_ISH = "{(#{(Taxt::TAXON_TAGS + Taxt::PROTONYM_TAGS).join('|')}) [0-9]+}"

    REF = "{#{Taxt::REF_TAG} [0-9]+}"

    ROMAN_NUMERALS = 'ivxlcdm'
    PAGINATION_WORDS = [
      'description',
      'error',
      'footnote',
      'in key',
      'in list',
      'in table',
      'in text',
      'redescription'
    ]
    PAGINATION = "([0-9]+|[#{ROMAN_NUMERALS}]+)( \\((#{PAGINATION_WORDS.join('|')})\\))?"
    PAGINATION_MANY = "(#{PAGINATION}, )*#{PAGINATION}"
    PAGINATION_MANY_EXACT = "^(#{PAGINATION}, )*#{PAGINATION}$"
    CITATION = "#{REF}: #{PAGINATION_MANY}"
    TRAILING_CITATION = "; #{CITATION}"
    CITATIONS = "#{CITATION}(#{TRAILING_CITATION})*"

    MISSPELLING = "{#{Taxt::MISSPELLING_TAG} (<i>)?[A-Za-z0-9 ä-]+(<\/i>)?}"
    UNMISSING = "{#{Taxt::UNMISSING_TAG} (<i>)?[A-Za-z]+(<\/i>)?}"

    # See also https://antcat.org/wiki/5
    FORMS = %w[
      aq.
      dq.
      em.
      eq.
      k.
      l.
      m.
      q.
      q.m.
      s.
      w.
    ]
    FORMS_ALT_FORMATS = [
      'l',
      'm',
      'q',
      'ergatoid m.',
      'ergatoid q.',
      'e.q.'
    ]
    FORMS_NON_STANDARD = [
      'putative m.',
      'putative q.',
      'polymorphic m.',
      'subapterous q.',
      'putative w.q.m.',
      'brachypterous q. ergatoid q. m.',
      'gynandromorph',
      'ergatandromorph',
      'pseudogyne',
      'gynecoid w.',
      'q.m. ergatoid',
      'q. ergatoid'
    ]
    FORM_CHARACTERS = FORMS.join.chars.uniq.join

    NOT_IMPLEMENTED = 'not_implemented'

    NON_STANDARD_FORMATS = [
      TAXT_FORMAT = {
        name: History::Definitions::TAXT,
        type: History::Definitions::TAXT
      }
    ]

    STANDARD_FORMAT_VARIATIONS = [
      HOMONYM_REPLACED_BY__WITH_SOURCE = 'HOMONYM_REPLACED_BY__WITH_SOURCE'
    ]

    STANDARD_FORMAT_CANDIDATES = [
      JUNIOR_SYNONYM_OF__GENUS_OR_FAMILY_GROUP = 'JUNIOR_SYNONYM_OF__GENUS_OR_FAMILY_GROUP',
      SENIOR_SYNONYM_OF__GENUS_OR_FAMILY_GROUP = 'SENIOR_SYNONYM_OF__GENUS_OR_FAMILY_GROUP',
      UNIDENTIFIABLE_TAXON = 'UNIDENTIFIABLE_TAXON',
      AS_SUBFAMILY_OF = 'AS_SUBFAMILY_OF',
      AS_TRIBE_OF = 'AS_TRIBE_OF',
      AS_SUBTRIBE_OF = 'AS_SUBTRIBE_OF',
      AS_GENUS = 'AS_GENUS',
      AS_SUBGENUS_OF = 'AS_SUBGENUS_OF',
      X_IN_X = 'X_IN_X',
      X_IN_UNMISSING = 'X_IN_UNMISSING',
      X_IN_X_X = 'X_IN_X_X',
      X_INCERTAE_SEDIS_IN_X = 'X_INCERTAE_SEDIS_IN_X',
      UNNECESSARY_REPLACEMENT_NAME_FOR = 'UNNECESSARY_REPLACEMENT_NAME_FOR',
      UNNECESSARY_REPLACEMENT_NAME_FOR__AFTER_FIRST = 'UNNECESSARY_REPLACEMENT_NAME_FOR__AFTER_FIRST',
      MATERIAL_REFERRED_TO_BY = 'MATERIAL_REFERRED_TO_BY',
      UNAVAILABLE_NAME_AND_MATERIAL_REFERRED_TO_BY = 'UNAVAILABLE_NAME_AND_MATERIAL_REFERRED_TO_BY',
      AS_UNAVAILABLE_INFRASUBSPECIFIC_NAME = 'AS_UNAVAILABLE_INFRASUBSPECIFIC_NAME',
      DECLARED_AS_UNAVAILABLE_INFRASUBSPECIFIC_NAME = 'DECLARED_AS_UNAVAILABLE_INFRASUBSPECIFIC_NAME',
      FIRST_AVAILABLE_USE_OF_UNAVAILABLE_INFRASUBSPECIFIC_NAME =
        'FIRST_AVAILABLE_USE_OF_UNAVAILABLE_INFRASUBSPECIFIC_NAME',
      FIRST_AVAILABLE_USE_OF_UNAVAILABLE_INFRASUBSPECIFIC_NAME__WITH_SOURCE =
        'FIRST_AVAILABLE_USE_OF_UNAVAILABLE_INFRASUBSPECIFIC_NAME__WITH_SOURCE',
      ALSO_DESCRIBED_AS_NEW_BY__SPECIES_GROUP = 'ALSO_DESCRIBED_AS_NEW_BY__SPECIES_GROUP',
      ALSO_DESCRIBED_AS_NEW_BY__GENUS_GROUP = 'ALSO_DESCRIBED_AS_NEW_BY__GENUS_GROUP',
      MISSPELLED_AS_BY = 'MISSPELLED_AS_BY'
    ]

    # Deprecated styles, added to make it possible to filter it out.
    DEPRECATED_FORMATS = [
      SEE_ALSO = 'SEE_ALSO',
      REVIVED_STATUS_AS_SPECIES = 'REVIVED_STATUS_AS_SPECIES',
      RAISED_TO_SPECIES = 'RAISED_TO_SPECIES'
    ]

    # [grep:history_type].
    # NOTE: Regexes as MySQL-compatiable strings.
    STANDARD_FORMATS = [
      {
        regex: "^#{CITATION} \\([#{FORMS}]+\\)\\.?$",
        name: History::Definitions::FORM_DESCRIPTIONS,
        type: History::Definitions::FORM_DESCRIPTIONS
      },
      {
        regex: "^Lectotype designation: #{CITATION}\\.?$",
        name: History::Definitions::LECTOTYPE_DESIGNATION,
        type: History::Definitions::TYPE_SPECIMEN_DESIGNATION,
        subtype: History::Definitions::LECTOTYPE_DESIGNATION
      },
      {
        regex: "^Neotype designation: #{CITATION}\\.?$",
        name: History::Definitions::NEOTYPE_DESIGNATION,
        type: History::Definitions::TYPE_SPECIMEN_DESIGNATION,
        subtype: History::Definitions::NEOTYPE_DESIGNATION
      },
      {
        regex: "^Combination in #{TAX_ISH}: #{CITATION}\\.?$",
        name: History::Definitions::COMBINATION_IN,
        type: History::Definitions::COMBINATION_IN
      },
      {
        regex: "^Junior synonym of #{PROTT}: #{CITATION}\\.?$",
        name: History::Definitions::JUNIOR_SYNONYM_OF,
        type: History::Definitions::JUNIOR_SYNONYM_OF
      },
      {
        regex: "^Senior synonym of #{PROTT}: #{CITATION}\\.?$",
        name: History::Definitions::SENIOR_SYNONYM_OF,
        type: History::Definitions::SENIOR_SYNONYM_OF
      },
      {
        regex: "^Status as species: #{CITATION}\\.?$",
        name: History::Definitions::STATUS_AS_SPECIES,
        type: History::Definitions::STATUS_AS_SPECIES
      },
      {
        regex: "^Subspecies of #{TAX_ISH}: #{CITATION}\\.?$",
        name: History::Definitions::SUBSPECIES_OF,
        type: History::Definitions::SUBSPECIES_OF
      },
      {
        regex: "^Replacement name: #{TAX_OR_PRO_ISH}\\.?$",
        name: History::Definitions::HOMONYM_REPLACED_BY,
        type: History::Definitions::HOMONYM_REPLACED_BY
      },
      {
        regex: "^Replacement name: #{TAX_OR_PRO_ISH} \\(#{CITATION}\\)\\.?$",
        name: HOMONYM_REPLACED_BY__WITH_SOURCE,
        type: History::Definitions::HOMONYM_REPLACED_BY
      },
      {
        regex: "^Replacement name for #{TAX_OR_PRO_ISH}\\.?$",
        name: History::Definitions::REPLACEMENT_NAME_FOR,
        type: History::Definitions::REPLACEMENT_NAME_FOR
      },

      # Future definition candidates.
      {
        regex: "^#{TAX_OR_PRO_ISH} as junior synonym of #{TAX_OR_PRO_ISH}: #{CITATION}\\.?$",
        name: JUNIOR_SYNONYM_OF__GENUS_OR_FAMILY_GROUP,
        type: JUNIOR_SYNONYM_OF__GENUS_OR_FAMILY_GROUP
      },
      {
        regex: "^#{TAX_OR_PRO_ISH} as senior synonym of #{TAX_OR_PRO_ISH}: #{CITATION}\\.?$",
        name: SENIOR_SYNONYM_OF__GENUS_OR_FAMILY_GROUP,
        type: SENIOR_SYNONYM_OF__GENUS_OR_FAMILY_GROUP
      },
      {
        regex: "^Unidentifiable taxon: #{CITATION}\\.?$",
        name: UNIDENTIFIABLE_TAXON,
        type: UNIDENTIFIABLE_TAXON
      },
      {
        regex: "^#{TAX_OR_PRO_ISH} as subfamily of #{TAX_OR_PRO_ISH}: #{CITATION}\\.?$",
        name: AS_SUBFAMILY_OF,
        type: AS_SUBFAMILY_OF
      },
      {
        regex: "^#{TAX_OR_PRO_ISH} as tribe of #{TAX_OR_PRO_ISH}: #{CITATION}\\.?$",
        name: AS_TRIBE_OF,
        type: AS_TRIBE_OF
      },
      {
        regex: "^#{TAX_OR_PRO_ISH} as subtribe of #{TAX_OR_PRO_ISH}: #{CITATION}\\.?$",
        name: AS_SUBTRIBE_OF,
        type: AS_SUBTRIBE_OF
      },
      {
        regex: "^#{TAX_OR_PRO_ISH} as genus: #{CITATION}\\.?$",
        name: AS_GENUS,
        type: AS_GENUS
      },
      {
        regex: "^#{TAX_OR_PRO_ISH} as subgenus of #{TAX_OR_PRO_ISH}: #{CITATION}\\.?$",
        name: AS_SUBGENUS_OF,
        type: AS_SUBGENUS_OF
      },
      {
        regex: "^#{TAX_OR_PRO_ISH} in #{TAX_OR_PRO_ISH}: #{CITATION}\\.?$",
        name: X_IN_X,
        type: X_IN_X
      },
      {
        regex: "^#{TAX_OR_PRO_ISH} in #{UNMISSING}: #{CITATION}\\.?$",
        name: X_IN_UNMISSING,
        type: X_IN_UNMISSING
      },
      {
        regex: "^#{TAX_OR_PRO_ISH} in #{TAX_OR_PRO_ISH}, #{TAX_OR_PRO_ISH}: #{CITATION}\\.?$",
        name: X_IN_X_X,
        type: X_IN_X_X
      },
      {
        regex: "^#{TAX_OR_PRO_ISH} <i>incertae sedis<\/i> in #{TAX_OR_PRO_ISH}: #{CITATION}\\.?$",
        name: X_INCERTAE_SEDIS_IN_X,
        type: X_INCERTAE_SEDIS_IN_X
      },
      {
        regex: "^Unnecessary replacement name for #{TAX_OR_PRO_ISH}\\.?$",
        name: UNNECESSARY_REPLACEMENT_NAME_FOR,
        type: UNNECESSARY_REPLACEMENT_NAME_FOR
      },
      {
        regex: "^Unnecessary \\((second|third|fourth)\\) replacement name for #{TAX_OR_PRO_ISH}\\.?$",
        name: UNNECESSARY_REPLACEMENT_NAME_FOR__AFTER_FIRST,
        type: UNNECESSARY_REPLACEMENT_NAME_FOR__AFTER_FIRST
      },
      {
        regex: "^Material referred to #{TAX_ISH} by #{CITATIONS}\.?$",
        name: MATERIAL_REFERRED_TO_BY,
        type: MATERIAL_REFERRED_TO_BY
      },
      {
        regex: "^Unavailable name; material referred to #{TAX_ISH} by #{CITATIONS}\.?$",
        name: UNAVAILABLE_NAME_AND_MATERIAL_REFERRED_TO_BY,
        type: UNAVAILABLE_NAME_AND_MATERIAL_REFERRED_TO_BY
      },
      {
        regex: "^As unavailable \\(infrasubspecific\\) name: #{CITATIONS}\.?$",
        name: AS_UNAVAILABLE_INFRASUBSPECIFIC_NAME,
        type: AS_UNAVAILABLE_INFRASUBSPECIFIC_NAME
      },
      {
        regex: "^Declared as unavailable \\(infrasubspecific\\) name: #{CITATIONS}\.?$",
        name: DECLARED_AS_UNAVAILABLE_INFRASUBSPECIFIC_NAME,
        type: DECLARED_AS_UNAVAILABLE_INFRASUBSPECIFIC_NAME
      },
      {
        regex: "^\\[First available use of #{TAXAC}; unavailable \\(infrasubspecific\\) name\.?\\]$",
        name: FIRST_AVAILABLE_USE_OF_UNAVAILABLE_INFRASUBSPECIFIC_NAME,
        type: FIRST_AVAILABLE_USE_OF_UNAVAILABLE_INFRASUBSPECIFIC_NAME
      },
      {
        regex: "^\\[First available use of #{TAXAC}; unavailable \\(infrasubspecific\\) name \\(#{CITATION}\\)\.?\\]$",
        name: FIRST_AVAILABLE_USE_OF_UNAVAILABLE_INFRASUBSPECIFIC_NAME__WITH_SOURCE,
        type: FIRST_AVAILABLE_USE_OF_UNAVAILABLE_INFRASUBSPECIFIC_NAME__WITH_SOURCE
      },
      {
        regex: "^\\[#{TAX_OR_PRO_ISH} also described as new by #{CITATION}\.?\\]$",
        name: ALSO_DESCRIBED_AS_NEW_BY__GENUS_GROUP,
        type: ALSO_DESCRIBED_AS_NEW_BY__GENUS_GROUP
      },
      {
        regex: "^\\[Also described as new by #{CITATIONS}\.?\\]$",
        name: ALSO_DESCRIBED_AS_NEW_BY__SPECIES_GROUP,
        type: ALSO_DESCRIBED_AS_NEW_BY__SPECIES_GROUP
      },
      {
        regex: "^\\[Misspelled as #{MISSPELLING} by #{CITATIONS}\.?\\]$",
        name: MISSPELLED_AS_BY,
        type: MISSPELLED_AS_BY
      },

      # Deprecated.
      {
        regex: "^See also: #{CITATIONS}\.?$",
        name: SEE_ALSO,
        type: SEE_ALSO
      },
      {
        regex: "^Raised to species: #{CITATIONS}\.?$",
        name: RAISED_TO_SPECIES,
        type: RAISED_TO_SPECIES
      },
      {
        regex: "^Revived status as species: #{CITATIONS}\.?$",
        name: REVIVED_STATUS_AS_SPECIES,
        type: REVIVED_STATUS_AS_SPECIES
      }
    ]

    attr_private_initialize :taxt

    def standard?
      return false if taxt.blank?
      identified_type != History::Definitions::TAXT
    end

    def identified_format
      return TAXT_FORMAT if taxt.blank?

      @_identified_format ||= STANDARD_FORMATS.find do |standard_format|
        taxt.match?(standard_format[:regex])
      end || TAXT_FORMAT
    end

    def deprecated?
      identified_type.in?(DEPRECATED_FORMATS)
    end

    def identified_type
      identified_format[:type]
    end
  end
end
