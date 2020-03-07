class SpeciesGroupTaxon < Taxon
  belongs_to :subfamily
  belongs_to :genus
  belongs_to :subgenus

  validates :genus, presence: true
  validate :ensure_protonym_is_a_species_group_name

  def recombination?
    return false unless protonym.name.is_a?(SpeciesGroupName)
    name.genus_epithet != protonym.name.genus_epithet
  end

  private

    def ensure_protonym_is_a_species_group_name
      return if protonym.name.is_a?(SpeciesGroupName)
      errors.add :base, "Species and subspecies must have protonyms with species-group names"
    end
end
