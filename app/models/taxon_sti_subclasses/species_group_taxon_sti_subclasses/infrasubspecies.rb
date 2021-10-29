# frozen_string_literal: true

class Infrasubspecies < SpeciesGroupTaxon
  belongs_to :species
  belongs_to :subspecies

  validates :status, inclusion: { in: Status::STATUSES - [Status::VALID], message: 'is not allowed for rank.' }

  validates(*(TAXA_COLUMNS - [:subfamily_id, :genus_id, :species_id, :subspecies_id]), absence: true)

  def parent
    subspecies
  end

  def parent= parent_taxon
    raise Taxa::InvalidParent.new(self, parent_taxon) unless parent_taxon.is_a?(Subspecies)

    self.subfamily = parent_taxon.subfamily
    self.genus = parent_taxon.genus
    self.species = parent_taxon.species
    self.subspecies = parent_taxon
  end

  def update_parent _new_parent
    raise "cannot update parent of infrasubspecies"
  end

  def immediate_children
    Taxon.none
  end
end
