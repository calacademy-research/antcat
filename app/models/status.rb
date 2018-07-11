class Status
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
    NONCONFORMING_SYNONYM     = "nonconforming synonym",
    UNAVAILABLE_UNCATEGORIZED = "unavailable uncategorized"
  ]

  # Order matters, see `spec/decorators/taxon_decorator/statistics_spec.rb`.
  def self.statuses
    @_statuses ||= [
      [VALID,                     'valid'],
      [SYNONYM,                   'synonyms'],
      [HOMONYM,                   'homonyms'],
      [UNIDENTIFIABLE,            'unidentifiable'],
      [UNAVAILABLE,               'unavailable'],
      [EXCLUDED_FROM_FORMICIDAE,  'excluded from Formicidae'],
      [ORIGINAL_COMBINATION,      'original combinations'],
      [COLLECTIVE_GROUP_NAME,     'collective group names'],
      [OBSOLETE_COMBINATION,      'obsolete combinations'],
      [UNAVAILABLE_MISSPELLING,   'unavailable misspellings'],
      [NONCONFORMING_SYNONYM,     'nonconforming synonyms'],
      [UNAVAILABLE_UNCATEGORIZED, 'unavailable uncategorized']
    ].map do |label, plural_label|
      Status.new label: label, plural_label: plural_label
    end
  end

  def self.find identifier
    identifier = identifier.status if identifier.kind_of? Taxon
    statuses.find { |status| status.includes? identifier } or raise "Couldn't find status for '#{identifier}'"
  end
  class << self; alias_method :[], :find end

  def self.ordered_statuses
    statuses.map &:to_s
  end

  def self.options_for_select
    statuses.map &:option_for_select
  end

  def initialize hash
    @hash = hash
  end

  def to_s *options
    numeric_argument = options.find { |option| option.kind_of? Numeric }
    options << :plural if numeric_argument && numeric_argument > 1

    if options.include?(:plural)
      @hash[:plural_label]
    else
      @hash[:label]
    end.dup
  end

  def includes? identifier
    @hash.values.include? identifier
  end

  def option_for_select
    [@hash[:label], @hash[:label]]
  end
end
