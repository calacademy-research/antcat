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
    s.downcase! unless options.include? :capitalized
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

    lll{%q{@_ranks}}
    rank = ranks.find {|rank| rank.includes? identifier}
    unless rank
      require 'ruby-debug';debugger;'';
    end
    #raise "Couldn't find #{identifier}" unless rank
    rank
  end

  def self.ranks
    @_ranks ||= [
      Rank.new(string: 'Family',     plural_string: 'Families',     symbol: :family,     plural_symbol: :families,    klass: Family),
      Rank.new(string: 'Subfamily',  plural_string: 'Subfamilies',  symbol: :subfamily,  plural_symbol: :subfamilies, klass: Subfamily),
      Rank.new(string: 'Tribe',      plural_string: 'Tribes',       symbol: :tribe,      plural_symbol: :tribes,      klass: Tribe),
      Rank.new(string: 'Genus',      plural_string: 'Genera',       symbol: :genus,      plural_symbol: :genera,      klass: Genus),
      Rank.new(string: 'Subgenus',   plural_string: 'Subgenera',    symbol: :subgenus,   plural_symbol: :subgenera,   klass: Subgenus),
      Rank.new(string: 'Species',    plural_string: 'Species',      symbol: :species,    plural_symbol: :species,     klass: Species),
      Rank.new(string: 'Subspecies', plural_string: 'Subspecies',   symbol: :subspecies, plural_symbol: :subspecies,  klass: Subspecies),
    ]
    lll{%q{@_ranks}}
  end
end

def Rank identifier
  Rank.find identifier
end
