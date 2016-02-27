class Rank
  def initialize hash
    @hash = hash
  end

  def string
    @hash[:string]
  end

  def uncommon?
    @hash[:uncommon]
  end

  # Returns only Genus for species and Family for genus.
  # Can't take subfamily or subgenus into consideration.
  # These cases should be handled in code where there is more information
  # avaiable.
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

  def to_sym *options
    if options.include? :plural
      @hash[:plural].to_sym
    else
      @hash[:string].to_sym
    end
  end

  def plural
    @hash[:plural]
  end

  def to_s *options
    numeric_argument = options.find {|option| option.kind_of? Numeric}
    options << :plural if numeric_argument && numeric_argument > 1 #hmm

    s = (options.include?(:plural) ? @hash[:plural] : @hash[:string]).dup
    s = s.titleize if options.include? :capitalized
    s
  end

  def includes? identifier
    @hash.values.include? identifier
  end

  def index
    self.class.ranks.index do |rank|
      @hash[:string] == rank.string
    end
  end

  def self.find identifier
    return nil if identifier.blank?

    search_ranks_for_this =
      case identifier
      when Taxon
        identifier.class.name.downcase
      when Enumerable, ActiveRecord::Relation
        identifier.first.class.name.downcase
      else
        "#{identifier}".downcase
      end

    ranks.find { |rank| rank.includes? search_ranks_for_this } or raise "Couldn't find rank for '#{identifier}'"
  end

  class << self; alias_method :[], :find end

  def self.ranks
    @_ranks ||= [
      Rank.new(string: 'family',     plural: 'families'),
      Rank.new(string: 'subfamily',  plural: 'subfamilies'),
      Rank.new(string: 'tribe',      plural: 'tribes', uncommon: true),
      Rank.new(string: 'genus',      plural: 'genera'),
      Rank.new(string: 'subgenus',   plural: 'subgenera', uncommon: true),
      Rank.new(string: 'species',    plural: 'species'),
      Rank.new(string: 'subspecies', plural: 'subspecies'),
    ]
  end

  private
    def at index
      self.class.ranks[index]
    end
end
