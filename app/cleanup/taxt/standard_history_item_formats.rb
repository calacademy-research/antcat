# frozen_string_literal: true

# See also https://antcat.org/wiki_pages/11

module Taxt
  class StandardHistoryItemFormats
    PROTT = "{#{Taxt::PROTT_TAG} [0-9]+}"
    PRO_ISH = "{(#{Taxt::PROTONYM_TAGS.join('|')}) [0-9]+}"

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

    # [grep:history_type].
    STANDARD_FORMATS = [
      {
        regex: "^#{CITATION_TAXT} \\([#{FORMS}]+\\).?$",
        name: History::Definitions::FORM_DESCRIPTIONS,
        type: History::Definitions::FORM_DESCRIPTIONS
      },
      {
        regex: "^Lectotype designation: #{CITATION_TAXT}\.?$",
        name: History::Definitions::LECTOTYPE_DESIGNATION,
        type: History::Definitions::TYPE_SPECIMEN_DESIGNATION,
        subtype: History::Definitions::LECTOTYPE_DESIGNATION
      },
      {
        regex: "^Neotype designation: #{CITATION_TAXT}\.?$",
        name: History::Definitions::NEOTYPE_DESIGNATION,
        type: History::Definitions::TYPE_SPECIMEN_DESIGNATION,
        subtype: History::Definitions::NEOTYPE_DESIGNATION
      },
      {
        regex: "^Junior synonym of #{PROTT}: #{CITATION_TAXT}\.?$",
        name: History::Definitions::JUNIOR_SYNONYM_OF,
        type: History::Definitions::JUNIOR_SYNONYM_OF
      },
      {
        regex: "^Senior synonym of #{PROTT}: #{CITATION_TAXT}\.?$",
        name: History::Definitions::SENIOR_SYNONYM_OF,
        type: History::Definitions::SENIOR_SYNONYM_OF
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
