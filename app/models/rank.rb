# coding: UTF-8
class Rank
  attr_reader :hash

  def initialize hash
    @hash = hash
  end

  #############
  def to_sym *options
    options.include?(:plural) ? @hash[:plural_symbol] : @hash[:symbol]
  end

  def to_s *options
    numeric_argument = options.find {|option| option.kind_of? Numeric}
    options << :plural if numeric_argument && numeric_argument > 1

    s = (options.include?(:plural) ? @hash[:plural_string] : @hash[:string]).dup
    s = s.titleize if options.include? :capitalized
    s
  end

  def to_class
    @hash[:klass]
  end
  #############

  def includes? identifier
    @hash.values.include? identifier
  end

  def self.find identifier
    identifier = identifier.class if identifier.kind_of? Taxon
    identifier = identifier.first.class if identifier.kind_of? Enumerable
    identifier = identifier.first.class if identifier.kind_of? ActiveRecord::Relation
    identifier = identifier.downcase if identifier.kind_of? String

    ranks.find {|rank| rank.includes? identifier} or raise "Couldn't find #{identifier}"
  end
  class << self; alias_method :[], :find end

  def self.ranks
    @_ranks ||= [
      Rank.new(string: 'family',     plural_string: 'families',     symbol: :family,     plural_symbol: :families,    klass: Family),
      Rank.new(string: 'subfamily',  plural_string: 'subfamilies',  symbol: :subfamily,  plural_symbol: :subfamilies, klass: Subfamily),
      Rank.new(string: 'tribe',      plural_string: 'tribes',       symbol: :tribe,      plural_symbol: :tribes,      klass: Tribe),
      Rank.new(string: 'genus',      plural_string: 'genera',       symbol: :genus,      plural_symbol: :genera,      klass: Genus),
      Rank.new(string: 'subgenus',   plural_string: 'subgenera',    symbol: :subgenus,   plural_symbol: :subgenera,   klass: Subgenus),
      Rank.new(string: 'species',    plural_string: 'species',      symbol: :species,    plural_symbol: :species,     klass: Species),
      Rank.new(string: 'subspecies', plural_string: 'subspecies',   symbol: :subspecies, plural_symbol: :subspecies,  klass: Subspecies),
    ]
  end
end
