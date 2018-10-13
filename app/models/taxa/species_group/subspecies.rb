class Subspecies < SpeciesGroupTaxon
  class NoSpeciesForSubspeciesError < StandardError; end

  belongs_to :species

  before_validation :set_genus

  def parent
    species || genus
  end

  def parent= parent_taxon
    if parent_taxon.is_a? Subgenus
      raise "we probably do not support this"
    end
    self.species = parent_taxon
  end

  def update_parent new_parent
    super
    self.genus = new_parent.genus if new_parent.genus
    self.subgenus = new_parent.subgenus if new_parent.subgenus
    self.species = new_parent
  end

  # TODO remove?
  def children
    Subspecies.none
  end

  def statistics valid_only: false
  end

  private

    def set_genus
      return if genus
      self.genus = species.genus if species
    end
end
