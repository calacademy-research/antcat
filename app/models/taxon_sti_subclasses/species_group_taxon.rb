# frozen_string_literal: true

class SpeciesGroupTaxon < Taxon
  belongs_to :subfamily, optional: true
  belongs_to :genus
  belongs_to :subgenus, optional: true

  validate :ensure_protonym_is_a_species_group_name

  # TODO: Do not calculate by string comparison because it does not handle homonyms,
  # or incorrect spellings (which should not have parentheses per ICZN 51.3.1).
  def recombination?
    return false unless protonym.name.is_a?(SpeciesGroupName)
    name.genus_epithet != protonym.name.genus_epithet
  end

  private

    def ensure_protonym_is_a_species_group_name
      return if protonym.name.is_a?(SpeciesGroupName)
      errors.add :base, "Species and subspecies must have protonyms with species-group names"
    end

    def ensure_name_can_be_changed! name_string
      existing_names = Name.joins(:taxa).where.not(id: name.id).where(name: name_string)
      raise Taxa::TaxonExists, existing_names if existing_names.any?
    end
end
