# frozen_string_literal: true

class Status
  STATUSES = [
    VALID                     = "valid",
    SYNONYM                   = "synonym",
    HOMONYM                   = "homonym",
    UNIDENTIFIABLE            = "unidentifiable",
    UNAVAILABLE               = "unavailable",
    EXCLUDED_FROM_FORMICIDAE  = "excluded from Formicidae",
    OBSOLETE_COMBINATION      = "obsolete combination",
    UNAVAILABLE_MISSPELLING   = "unavailable misspelling"
  ]

  PLURALS = {
    SYNONYM                   => 'synonyms',
    HOMONYM                   => 'homonyms',
    OBSOLETE_COMBINATION      => 'obsolete combinations',
    UNAVAILABLE_MISSPELLING   => 'unavailable misspellings'
  }

  PASS_THROUGH_NAMES = [OBSOLETE_COMBINATION, UNAVAILABLE_MISSPELLING]
  TERMINAL_STATUSES = STATUSES - PASS_THROUGH_NAMES
  DISPLAY_HISTORY_ITEMS_VIA_PROTONYM_STATUSES = TERMINAL_STATUSES

  CURRENT_TAXON_VALIDATION = {
    presence: [
      SYNONYM,
      OBSOLETE_COMBINATION,
      UNAVAILABLE_MISSPELLING
    ],
    absence: [
      VALID,
      UNIDENTIFIABLE,
      UNAVAILABLE,
      EXCLUDED_FROM_FORMICIDAE,
      HOMONYM
    ]
  }

  ALLOWED_STATUSES_OF_CURRENT_TAXON = {
    OBSOLETE_COMBINATION => [
      VALID,
      SYNONYM,
      HOMONYM,
      UNIDENTIFIABLE,
      UNAVAILABLE,
      EXCLUDED_FROM_FORMICIDAE,
      UNAVAILABLE_MISSPELLING
    ]
  }

  class << self
    def plural status
      PLURALS[status] || status
    end

    def cannot_have_current_taxon? status
      status.in? CURRENT_TAXON_VALIDATION[:absence]
    end

    def requires_current_taxon? status
      status.in? CURRENT_TAXON_VALIDATION[:presence]
    end

    def status_of_current_taxon_allowed? taxon_status, status_of_current_taxon
      status_of_current_taxon.in? ALLOWED_STATUSES_OF_CURRENT_TAXON.fetch(taxon_status)
    end

    # TODO: History items may be rank-specific.
    def display_history_items? taxon_status
      raise 'unknown status' unless taxon_status.in?(STATUSES)
      taxon_status.in?(DISPLAY_HISTORY_ITEMS_VIA_PROTONYM_STATUSES)
    end
  end
end
