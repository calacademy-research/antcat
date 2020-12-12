# frozen_string_literal: true

# See also https://antcat.org/wiki_pages/11

module Taxt
  class StandardHistoryItemFormats
    PROTT = "{prott [0-9]+}"
    PRO_ISH = "{(pro|proac|prott) [0-9]+}"

    REF = "{ref [0-9]+}"
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
        name: TAXT = HistoryItem::TAXT,
        type: HistoryItem::TAXT
      }
    ]

    # [grep:history_type].
    STANDARD_FORMATS = [
      {
        regex: "^#{CITATION_TAXT} \\([#{FORMS}]+\\).?$",
        name: HistoryItem::FORM_DESCRIPTIONS,
        type: HistoryItem::FORM_DESCRIPTIONS
      },
      {
        regex: "^Lectotype designation: #{CITATION_TAXT}\.?$",
        name: HistoryItem::LECTOTYPE_DESIGNATION,
        type: HistoryItem::TYPE_SPECIMEN_DESIGNATION,
        subtype: HistoryItem::LECTOTYPE_DESIGNATION
      },
      {
        regex: "^Neotype designation: #{CITATION_TAXT}\.?$",
        name: HistoryItem::NEOTYPE_DESIGNATION,
        type: HistoryItem::TYPE_SPECIMEN_DESIGNATION,
        subtype: HistoryItem::NEOTYPE_DESIGNATION
      },
      {
        regex: "^Junior synonym of #{PROTT}: #{CITATION_TAXT}\.?$",
        name: HistoryItem::JUNIOR_SYNONYM_OF,
        type: HistoryItem::JUNIOR_SYNONYM_OF
      },
      {
        regex: "^Senior synonym of #{PROTT}: #{CITATION_TAXT}\.?$",
        name: HistoryItem::SENIOR_SYNONYM_OF,
        type: HistoryItem::SENIOR_SYNONYM_OF
      }
    ]

    attr_private_initialize :taxt

    def standard?
      return false if taxt.blank?
      identified_type != TAXT
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
