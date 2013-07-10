# coding: UTF-8
class Rank
  def initialize hash
    @hash = hash
  end

  def string
    @hash[:string]
  end

  def display_string
    string.titlecase
  end
  def uncommon?
    @hash[:uncommon]
  end

  def parent
    parent_index = index - 1
    return nil if parent_index < 0
    parent = at parent_index
    parent = parent.parent if parent.uncommon?
    parent
  end

  def child
    child_index = index + 1
    return nil if child_index >= self.class.ranks.size
    child = at child_index
    child = child.child if child.uncommon?
    child
  end

  def write_selector
    "#{@hash[:string]}=".to_sym
  end

  def read_selector
    "#{@hash[:string]}".to_sym
  end

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

  def includes? identifier
    @hash.values.include? identifier
  end

  def index
    self.class.ranks.index do |rank|
      @hash[:string] == rank.string
    end
  end

  def at index
    self.class.ranks[index]
  end

  def self.find identifier
    return nil if identifier.blank?
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
      Rank.new(string: 'tribe',      plural_string: 'tribes',       symbol: :tribe,      plural_symbol: :tribes,      klass: Tribe, uncommon: true),
      Rank.new(string: 'genus',      plural_string: 'genera',       symbol: :genus,      plural_symbol: :genera,      klass: Genus),
      Rank.new(string: 'subgenus',   plural_string: 'subgenera',    symbol: :subgenus,   plural_symbol: :subgenera,   klass: Subgenus, uncommon: true),
      Rank.new(string: 'species',    plural_string: 'species',      symbol: :species,    plural_symbol: :species,     klass: Species),
      Rank.new(string: 'subspecies', plural_string: 'subspecies',   symbol: :subspecies, plural_symbol: :subspecies,  klass: Subspecies),
    ]
  end

end
