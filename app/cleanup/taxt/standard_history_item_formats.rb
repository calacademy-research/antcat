# frozen_string_literal: true

# See also https://antcat.org/wiki_pages/11

module Taxt
  class StandardHistoryItemFormats
    PROTT = "{#{Taxt::PROTT_TAG} [0-9]+}"
    TAX = "{#{Taxt::TAX_TAG} [0-9]+}"
    TAXAC = "{#{Taxt::TAXAC_TAG} [0-9]+}"
    TAX_ISH = "{(#{Taxt::TAXON_TAGS.join('|')}) [0-9]+}"
    PRO_ISH = "{(#{Taxt::PROTONYM_TAGS.join('|')}) [0-9]+}"
    TAX_OR_PRO_ISH = "{(#{(Taxt::TAXON_TAGS + Taxt::PROTONYM_TAGS).join('|')}) [0-9]+}"

    REF = "{#{Taxt::REF_TAG} [0-9]+}"
    PAGES = "[0-9]+"
    CITATION_TAXT = "#{REF}: #{PAGES}"

    # See also https://antcat.org/wiki_pages/5
    FORMS = %w[
      aq.
      dq.
      em.
      eq.
      k.
      l.
      m.
      q.
      q.m
      s.
      w.
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
      REPLACEMENT_NAME__WITH_SOURCE = 'REPLACEMENT_NAME__WITH_SOURCE'
    ]

    STANDARD_FORMAT_CANDIDATES = [
      UNNECESSARY_REPLACEMENT_NAME_FOR = 'UNNECESSARY_REPLACEMENT_NAME_FOR',
      MATERIAL_REFERRED_TO_BY = 'MATERIAL_REFERRED_TO_BY',
      UNAVAILABLE_NAME_AND_MATERIAL_REFERRED_TO_BY = 'UNAVAILABLE_NAME_AND_MATERIAL_REFERRED_TO_BY',
      DECLARED_AS_UNAVAILABLE_INFRASUBSPECIFIC_NAME = 'DECLARED_AS_UNAVAILABLE_INFRASUBSPECIFIC_NAME',
      FIRST_AVAILABLE_USE_OF_UNAVAILABLE_INFRASUBSPECIFIC_NAME =
        'FIRST_AVAILABLE_USE_OF_UNAVAILABLE_INFRASUBSPECIFIC_NAME',
      FIRST_AVAILABLE_USE_OF_UNAVAILABLE_INFRASUBSPECIFIC_NAME__WITH_SOURCE =
        'FIRST_AVAILABLE_USE_OF_UNAVAILABLE_INFRASUBSPECIFIC_NAME__WITH_SOURCE'
    ]

    # [grep:history_type].
    # NOTE: Regexes as MySQL-compatiable strings.
    STANDARD_FORMATS = [
      {
        regex: "^#{CITATION_TAXT} \\([#{FORMS}]+\\)\\.?$",
        name: History::Definitions::FORM_DESCRIPTIONS,
        type: History::Definitions::FORM_DESCRIPTIONS
      },
      {
        regex: "^Lectotype designation: #{CITATION_TAXT}\\.?$",
        name: History::Definitions::LECTOTYPE_DESIGNATION,
        type: History::Definitions::TYPE_SPECIMEN_DESIGNATION,
        subtype: History::Definitions::LECTOTYPE_DESIGNATION
      },
      {
        regex: "^Neotype designation: #{CITATION_TAXT}\\.?$",
        name: History::Definitions::NEOTYPE_DESIGNATION,
        type: History::Definitions::TYPE_SPECIMEN_DESIGNATION,
        subtype: History::Definitions::NEOTYPE_DESIGNATION
      },
      {
        regex: "^Combination in #{TAX_ISH}: #{CITATION_TAXT}\\.?$",
        name: History::Definitions::COMBINATION_IN,
        type: History::Definitions::COMBINATION_IN
      },
      {
        regex: "^Junior synonym of #{PROTT}: #{CITATION_TAXT}\\.?$",
        name: History::Definitions::JUNIOR_SYNONYM_OF,
        type: History::Definitions::JUNIOR_SYNONYM_OF
      },
      {
        regex: "^Senior synonym of #{PROTT}: #{CITATION_TAXT}\\.?$",
        name: History::Definitions::SENIOR_SYNONYM_OF,
        type: History::Definitions::SENIOR_SYNONYM_OF
      },
      {
        regex: "^Status as species: #{CITATION_TAXT}\\.?$",
        name: History::Definitions::STATUS_AS_SPECIES,
        type: History::Definitions::STATUS_AS_SPECIES
      },
      {
        regex: "^Subspecies of #{TAX_ISH}: #{CITATION_TAXT}\\.?$",
        name: History::Definitions::SUBSPECIES_OF,
        type: History::Definitions::SUBSPECIES_OF
      },
      {
        regex: "^Replacement name: #{TAX_OR_PRO_ISH}\\.?$",
        name: History::Definitions::REPLACEMENT_NAME,
        type: History::Definitions::REPLACEMENT_NAME
      },
      {
        regex: "^Replacement name: #{TAX_OR_PRO_ISH} \\(#{CITATION_TAXT}\\)\\.?$",
        name: REPLACEMENT_NAME__WITH_SOURCE,
        type: History::Definitions::REPLACEMENT_NAME
      },

      # Future definition candidates.
      {
        regex: "^Material referred to #{TAX} by #{CITATION_TAXT}\.?$",
        name: MATERIAL_REFERRED_TO_BY,
        type: MATERIAL_REFERRED_TO_BY
      },
      {
        regex: "^Unavailable name; material referred to #{TAX} by #{CITATION_TAXT}\.?$",
        name: UNAVAILABLE_NAME_AND_MATERIAL_REFERRED_TO_BY,
        type: UNAVAILABLE_NAME_AND_MATERIAL_REFERRED_TO_BY
      },
      {
        regex: "^Declared as unavailable \\(infrasubspecific\\) name: #{CITATION_TAXT}\.?$",
        name: DECLARED_AS_UNAVAILABLE_INFRASUBSPECIFIC_NAME,
        type: DECLARED_AS_UNAVAILABLE_INFRASUBSPECIFIC_NAME
      },
      {
        regex: "^\\[First available use of #{TAXAC}; unavailable \\(infrasubspecific\\) name\.?\\]$",
        name: FIRST_AVAILABLE_USE_OF_UNAVAILABLE_INFRASUBSPECIFIC_NAME,
        type: FIRST_AVAILABLE_USE_OF_UNAVAILABLE_INFRASUBSPECIFIC_NAME
      },
      {
        regex: "^\\[First available use of #{TAXAC}; unavailable \\(infrasubspecific\\) name \\(#{CITATION_TAXT}\\)\.?\\]$",
        name: FIRST_AVAILABLE_USE_OF_UNAVAILABLE_INFRASUBSPECIFIC_NAME__WITH_SOURCE,
        type: FIRST_AVAILABLE_USE_OF_UNAVAILABLE_INFRASUBSPECIFIC_NAME__WITH_SOURCE
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

    def identified_type
      identified_format[:type]
    end
  end
end
