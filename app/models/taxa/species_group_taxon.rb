class SpeciesGroupTaxon < Taxon
  belongs_to :subfamily
  belongs_to :genus
  belongs_to :subgenus

  validates :genus, presence: true
  validate :ensure_protonym_is_a_species_group_name

  def recombination?
    # TODO: Check if this is true.
    # To avoid `NoMethodError` for records with protonyms above genus rank.
    protonym_name = protonym.name
    return false unless protonym_name.respond_to?(:genus_epithet)

    name.genus_epithet != protonym_name.genus_epithet
  end

  private

    def ensure_protonym_is_a_species_group_name
      return if protonym.name.is_a?(SpeciesGroupName)
      errors.add :base, "Species and subspecies must have protonyms with species-group names"
    end
end
