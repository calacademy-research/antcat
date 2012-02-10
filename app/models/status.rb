# coding: UTF-8
class Status
  extend ActionView::Helpers::NumberHelper
  attr_reader :hash

  def initialize hash
    @hash = hash
  end

  def to_s *options
    numeric_argument = options.find {|option| option.kind_of? Numeric}
    options << :plural if numeric_argument && numeric_argument > 1

    s = (options.include?(:plural) ? @hash[:plural_label] : @hash[:label]).dup
    s.downcase! unless options.include? :capitalized
    s
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

  def self.statuses
    @_statuses ||= [
      Status.new(string: 'valid',               label: 'valid',
                                         plural_label: 'valid'),
      Status.new(string: 'synonym',             label: 'synonym',
                                         plural_label: 'synonyms'),
      Status.new(string: 'homonym',             label: 'homonym',
                                         plural_label: 'homonyms'),
      Status.new(string: 'unavailable',         label: 'unavailable',
                                         plural_label: 'unavailable'),
      Status.new(string: 'unidentifiable',      label: 'unidentifiable',
                                         plural_label: 'unidentifiable'),
      Status.new(string: 'excluded',            label: 'excluded',
                                         plural_label: 'excluded'),
      Status.new(string: 'unresolved homonym',  label: 'unresolved homonym',
                                         plural_label: 'unresolved homonyms'),
      Status.new(string: 'recombined',          label: 'transferred out of this genus',
                                         plural_label: 'transferred out of this genus'),
      Status.new(string: 'nomen nudum',         label: 'nomen nudum',
                                         plural_label: 'nomina nuda'),
    ]
    end
end
