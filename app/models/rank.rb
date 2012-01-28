# coding: UTF-8
class Rank
  attr_reader :hash

  def initialize hash
    @hash = hash
  end

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

  def includes? identifier
    @hash.values.include? identifier
  end

  def self.find identifier
    identifier = identifier.class if identifier.kind_of? Taxon
    identifier = identifier.first.class if identifier.kind_of? Enumerable

    ranks.find {|rank| rank.includes? identifier}
  end

  def self.ranks
    @_ranks ||= [
      Rank.new(string: 'Tribe', plural_string: 'Tribes', symbol: :tribe, plural_symbol: :tribes, klass: Tribe),
      Rank.new(string: 'Genus', plural_string: 'Genera', symbol: :genus, plural_symbol: :genera, klass: Genus),
    ]
  end
end

def Rank identifier
  Rank.find identifier
end
