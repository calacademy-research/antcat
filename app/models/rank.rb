class Rank
  attr_reader :singular, :plural, :string

  def initialize singular, plural, uncommon: false
    @singular = singular
    @plural = plural
    @uncommon = uncommon
  end

  def string
    @singular
  end

  def uncommon?
    @uncommon
  end

  # Returns only Genus for species and Family for genus.
  # Can't take subfamily or subgenus into consideration.
  # These cases should be handled in code where there is more information
  # available.
  def parent
    parent_index = index - 1
    return if parent_index < 0
    parent = at parent_index
    parent = parent.parent if parent.uncommon?
    parent
  end

  def child
    child_index = index + 1
    return if child_index >= self.class.ranks.size
    child = at child_index
    child = child.child if child.uncommon?
    child
  end

  def to_s *options
    numeric_argument = options.find {|option| option.kind_of? Numeric}
    options << :plural if numeric_argument && numeric_argument > 1 #hmm

    (options.include?(:plural) ? @plural : @singular).dup
  end

  def index
    self.class.ranks.index do |rank|
      @singular == rank.string
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

    ranks.find { |rank|
      rank.singular == search_ranks_for_this ||
      rank.plural == search_ranks_for_this
    } or raise "Couldn't find rank for '#{identifier}'"
  end

  class << self; alias_method :[], :find end

  def self.ranks
    @_ranks ||= [
      Rank.new("family", "families"),
      Rank.new("subfamily", "subfamilies"),
      Rank.new("tribe", "tribes", uncommon: true),
      Rank.new("genus", "genera"),
      Rank.new("subgenus", "subgenera", uncommon: true),
      Rank.new("species", "species"),
      Rank.new("subspecies", "subspecies")
    ]
  end

  private
    def at index
      self.class.ranks[index]
    end
end
