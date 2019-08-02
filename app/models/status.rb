class Status
  # Order matters, see `format_statistics_spec.rb`.
  STATUSES = [
    VALID                     = "valid",
    SYNONYM                   = "synonym",
    HOMONYM                   = "homonym",
    UNIDENTIFIABLE            = "unidentifiable",
    UNAVAILABLE               = "unavailable",
    EXCLUDED_FROM_FORMICIDAE  = "excluded from Formicidae",
    OBSOLETE_COMBINATION      = "obsolete combination",
    UNAVAILABLE_MISSPELLING   = "unavailable misspelling",
    UNAVAILABLE_UNCATEGORIZED = "unavailable uncategorized"
  ]

  PLURALS = {
    SYNONYM                   => 'synonyms',
    HOMONYM                   => 'homonyms',
    OBSOLETE_COMBINATION      => 'obsolete combinations',
    UNAVAILABLE_MISSPELLING   => 'unavailable misspellings',
    UNAVAILABLE_UNCATEGORIZED => 'unavailable uncategorized'
  }

  PASS_THROUGH_NAMES = [OBSOLETE_COMBINATION, UNAVAILABLE_MISSPELLING]
  UNDISPLAYABLE = [UNAVAILABLE_MISSPELLING, UNAVAILABLE_UNCATEGORIZED]

  CURRENT_VALID_TAXON_VALIDATION = {
    presence: [
      SYNONYM,
      OBSOLETE_COMBINATION,
      UNAVAILABLE_MISSPELLING,
      UNAVAILABLE_UNCATEGORIZED
    ],
    absence: [
      VALID,
      UNIDENTIFIABLE,
      UNAVAILABLE,
      EXCLUDED_FROM_FORMICIDAE,
      HOMONYM
    ]
  }

  def self.plural status
    PLURALS[status] || status
  end
end
