class Rank
  def initialize name, uncommon: false
    @name = name
    @uncommon = uncommon
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

  def to_s
    "#{@name}"
  end

  def index
    self.class.ranks.index do |rank|
      self.to_s == rank.to_s
    end
  end

  def self.find identifier
    return if identifier.blank?

    rank_to_find =
      case identifier
      when Taxon
        identifier.class.name.downcase
      else
        "#{identifier}".singularize.downcase
      end

    ranks.find { |rank| rank.to_s == rank_to_find } or raise "Couldn't find rank for '#{identifier}'"
  end

  class << self; alias_method :[], :find end

  def self.ranks
    @_ranks ||= [
      Rank.new("family"),
      Rank.new("subfamily"),
      Rank.new("tribe", uncommon: true),
      Rank.new("genus"),
      Rank.new("subgenus", uncommon: true),
      Rank.new("species"),
      Rank.new("subspecies")
    ]
  end

  private
    def at index
      self.class.ranks[index]
    end
end
