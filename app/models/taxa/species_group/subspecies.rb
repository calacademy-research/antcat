class Subspecies < SpeciesGroupTaxon
  belongs_to :species

  before_validation :set_genus

  def parent
    species || genus
  end

  def parent= parent_taxon
    raise InvalidParent.new(self, parent_taxon) unless parent_taxon.is_a?(Species)

    self.subfamily = parent_taxon.subfamily
    self.genus = parent_taxon.genus
    self.subgenus = parent_taxon.subgenus
    self.species = parent_taxon
  end

  def update_parent new_parent
    name.change_parent(new_parent.name) unless new_parent == parent
    self.parent = new_parent
  end

  # TODO remove?
  def children
    Subspecies.none
  end

  private

    def set_genus
      return if genus
      self.genus = species.genus if species
    end
end
