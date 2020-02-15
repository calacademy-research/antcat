class Subspecies < SpeciesGroupTaxon
  belongs_to :species

  has_many :infrasubspecies, dependent: :restrict_with_error

  validates :species, presence: true

  before_validation :set_genus, on: :create # TODO: Remove callback.

  def parent
    species
  end

  def parent= parent_taxon
    raise Taxa::InvalidParent.new(self, parent_taxon) unless parent_taxon.is_a?(Species)

    self.subfamily = parent_taxon.subfamily
    self.genus = parent_taxon.genus
    self.subgenus = parent_taxon.subgenus
    self.species = parent_taxon
  end

  def update_parent new_parent
    raise Taxa::TaxonHasInfrasubspecies, 'Subspecies has infrasubspecies' if infrasubspecies.any?

    name.change_parent(new_parent.name) unless new_parent == parent
    self.parent = new_parent
  end

  def children
    infrasubspecies
  end

  def childrens_rank_in_words
    "infrasubspecies"
  end

  private

    def set_genus
      return if genus
      self.genus = species.genus
    end
end
