# coding: UTF-8
class Status
  extend ActionView::Helpers::NumberHelper

  def initialize hash
    @hash = hash
  end

  def to_s *options
    numeric_argument = options.find {|option| option.kind_of? Numeric}
    options << :plural if numeric_argument && numeric_argument > 1

    string = (options.include?(:plural) ? @hash[:plural_label] : @hash[:label]).dup
    string.downcase! unless options.include? :capitalized
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

    statuses.find {|status| status.includes? identifier} or raise "Couldn't find #{identifier}"
  end
  class << self; alias_method :[], :find end

  def self.options_for_select
    statuses.map {|status| status.option_for_select}
  end

  def option_for_select
    [@hash[:label], @hash[:string]]
  end

  def self.statuses
    @_statuses ||= [
      Status.new(string: 'valid',                   label: 'valid',
                                             plural_label: 'valid'),
      Status.new(string: 'synonym',                 label: 'synonym',
                                             plural_label: 'synonyms'),
      Status.new(string: 'homonym',                 label: 'homonym',
                                             plural_label: 'homonyms'),
      Status.new(string: 'unavailable',             label: 'unavailable',
                                             plural_label: 'unavailable'),
      Status.new(string: 'excluded',                label: 'excluded',
                                             plural_label: 'excluded'),
      Status.new(string: 'nomen nudum',             label: 'nomen nudum',
                                             plural_label: 'nomina nuda'),
      Status.new(string: 'ichnotaxon',              label: 'ichnotaxon',
                                             plural_label: 'ichnotaxa'),
      Status.new(string: 'collective group name',   label: 'Collective group name',
                                             plural_label: 'Collective group names'),
      Status.new(string: 'original combination',    label: 'original combination',
                                             plural_label: 'original combinations'),
    ]
    end
end
