class Subspecies < SpeciesGroupTaxon
  belongs_to :species

  has_many :infrasubspecies, dependent: :restrict_with_error

  validates :species, presence: true

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

    change_name!(new_parent.name) unless new_parent == parent
    self.parent = new_parent
  end

  def children
    infrasubspecies
  end

  def childrens_rank_in_words
    "infrasubspecies"
  end

  private

    def change_name! new_species_name
      name_string = [new_species_name.genus_epithet, new_species_name.species_epithet, name.subspecies_epithets].join ' '
      ensure_name_can_be_changed! name_string
      name.name = name_string
    end
end
