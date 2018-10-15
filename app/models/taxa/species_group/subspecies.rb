class Subspecies < SpeciesGroupTaxon
  belongs_to :species

  before_validation :set_genus

  def parent
    species || genus
  end

  def parent= parent_taxon
    raise InvalidParent.new(self, parent_taxon) unless parent_taxon.is_a?(Species)
    self.species = parent_taxon
  end

  def update_parent new_parent
    raise InvalidParent.new(self, new_parent) unless new_parent.is_a?(Species)
    return if parent == new_parent

    name.change_parent new_parent.name

    self.subfamily = new_parent.subfamily
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
