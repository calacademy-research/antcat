# frozen_string_literal: true

# See also https://antcat.org/wiki_pages/11

module Taxt
  class StandardHistoryItemFormats
    PROTT = "{prott [0-9]+}"
    PRO_ISH = "{(pro|proac|prott) [0-9]+}"
    REF = "{ref [0-9]+}"

    PAGES = "[0-9]+"
    CITATION = "#{REF}: #{PAGES}"

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

    FORMATS = [
      LECTOTYPE_DESIGNATION = "^Lectotype designation: #{CITATION}\.?$",
      NEOTYPE_DESIGNATION = "^Neotype designation: #{CITATION}\.?$",
      JUNIOR_SYNONYM_OF = "^Junior synonym of #{PROTT}: #{CITATION}\.?$",
      SENIOR_SYNONYM_OF = "^Senior synonym of #{PROTT}: #{CITATION}\.?$",
      FORM_DESCRIPTIONS = "^#{CITATION} \\([#{FORM_CHARACTERS}]+\\).?$"
    ]

    def self.standard? taxt
      return false if taxt.blank?
      FORMATS.any? { |regex| taxt.match?(regex) }
    end
  end
end
