# coding: UTF-8
class Status

  def initialize hash
    @hash = hash
  end

  def to_s *options
    numeric_argument = options.find {|option| option.kind_of? Numeric}
    options << :plural if numeric_argument && numeric_argument > 1 #hmm

    string = (options.include?(:plural) ? @hash[:plural_label] : @hash[:label]).dup
    string
  end

  def self.ordered_statuses
    statuses.map &:to_s
  end

  def includes? identifier
    @hash.values.include? identifier
  end

  def self.find identifier
    identifier = identifier.status if identifier.kind_of? Taxon
    identifier = identifier.first.status if identifier.kind_of? Enumerable
    identifier = identifier.first.status if identifier.kind_of? ActiveRecord::Relation

    statuses.find {|status| status.includes? identifier} or raise "Couldn't find status for '#{identifier}'"
  end
  class << self; alias_method :[], :find end

  def self.options_for_select
    statuses.reject(&:internal?).map {|status| status.option_for_select}
  end

  def internal?
    @hash[:internal]
  end

  def option_for_select
    [@hash[:label], @hash[:string]]
  end

  #joe - see if we can not display "unavailable uncategorized"
  def self.statuses
    @_statuses ||= [
      ['valid',                     'valid',                     'valid'],
      ['synonym',                   'synonym',                   'synonyms'],
      ['homonym',                   'homonym',                   'homonyms'],
      ['unidentifiable',            'unidentifiable',            'unidentifiable'],
      ['unavailable',               'unavailable',               'unavailable'],
      ['excluded from Formicidae',  'excluded from Formicidae',  'excluded from Formicidae'],
      ['original combination',      'original combination',      'original combinations'],
      ['collective group name',     'collective group name',     'collective group names'],
      ['obsolete combination',      'obsolete combination',      'obsolete combinations'],
      ['unavailable misspelling',   'unavailable misspelling',   'unavailable misspelling'],
      ['nonconforming synonym',     'nonconforming synonym',     'nonconforming synonym'],
      ['unavailable uncategorized', 'unavailable uncategorized', 'unavailable uncategorized']
    ].map do |status|
      Status.new(string: status.first, label: status.second, plural_label: status.third)
    end
  end

end
