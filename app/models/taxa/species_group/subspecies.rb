class Subspecies < SpeciesGroupTaxon
  belongs_to :species

  validates :species, presence: true

  before_validation :set_genus

  def parent
    species
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

  def children
    Subspecies.none
  end

  private

    def set_genus
      return if genus
      # TODO: `if species` is only here to satisfy specs. See if we want to change `before_validation`
      # to `before_save`, or simply not store `genus_id` for species.
      self.genus = species.genus if species
    end
end
