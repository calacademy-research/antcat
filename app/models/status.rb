class Status
  # Order matters, see `spec/decorators/taxon_decorator/statistics_spec.rb`.
  STATUSES = [
    VALID                     = "valid",
    SYNONYM                   = "synonym",
    HOMONYM                   = "homonym",
    UNIDENTIFIABLE            = "unidentifiable",
    UNAVAILABLE               = "unavailable",
    EXCLUDED_FROM_FORMICIDAE  = "excluded from Formicidae",
    ORIGINAL_COMBINATION      = "original combination", # TODO: Remove.
    OBSOLETE_COMBINATION      = "obsolete combination",
    UNAVAILABLE_MISSPELLING   = "unavailable misspelling",
    UNAVAILABLE_UNCATEGORIZED = "unavailable uncategorized"
  ]

  PLURALS = {
    SYNONYM                   => 'synonyms',
    HOMONYM                   => 'homonyms',
    ORIGINAL_COMBINATION      => 'original combinations',
    OBSOLETE_COMBINATION      => 'obsolete combinations',
    UNAVAILABLE_MISSPELLING   => 'unavailable misspellings',
    UNAVAILABLE_UNCATEGORIZED => 'unavailable uncategorized'
  }

  PASS_THROUGH_NAMES = [OBSOLETE_COMBINATION, ORIGINAL_COMBINATION, UNAVAILABLE_MISSPELLING]
  UNDISPLAYABLE = [UNAVAILABLE_MISSPELLING, UNAVAILABLE_UNCATEGORIZED]

  CURRENT_VALID_TAXON_VALIDATION = {
    presence: [
      SYNONYM,
      ORIGINAL_COMBINATION,
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
