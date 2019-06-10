class Status
  # Order matters, see `spec/decorators/taxon_decorator/statistics_spec.rb`.
  STATUSES = [
    VALID                     = "valid",
    SYNONYM                   = "synonym",
    HOMONYM                   = "homonym",
    UNIDENTIFIABLE            = "unidentifiable",
    UNAVAILABLE               = "unavailable",
    EXCLUDED_FROM_FORMICIDAE  = "excluded from Formicidae",
    ORIGINAL_COMBINATION      = "original combination",
    COLLECTIVE_GROUP_NAME     = "collective group name",
    OBSOLETE_COMBINATION      = "obsolete combination",
    UNAVAILABLE_MISSPELLING   = "unavailable misspelling",
    UNAVAILABLE_UNCATEGORIZED = "unavailable uncategorized"
  ]

  PLURALS = {
    SYNONYM                   => 'synonyms',
    HOMONYM                   => 'homonyms',
    ORIGINAL_COMBINATION      => 'original combinations',
    COLLECTIVE_GROUP_NAME     => 'collective group names',
    OBSOLETE_COMBINATION      => 'obsolete combinations',
    UNAVAILABLE_MISSPELLING   => 'unavailable misspellings',
    UNAVAILABLE_UNCATEGORIZED => 'unavailable uncategorized'
  }

  PASS_THROUGH_NAMES = [Status::OBSOLETE_COMBINATION, Status::ORIGINAL_COMBINATION, Status::UNAVAILABLE_MISSPELLING]
  UNDISPLAYABLE = [Status::UNAVAILABLE_MISSPELLING, Status::UNAVAILABLE_UNCATEGORIZED]

  def self.plural status
    PLURALS[status] || status
  end
end
