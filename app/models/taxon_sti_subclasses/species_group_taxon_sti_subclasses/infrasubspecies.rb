# frozen_string_literal: true

class Infrasubspecies < SpeciesGroupTaxon
  belongs_to :species
  belongs_to :subspecies

  def parent
    subspecies
  end

  def parent= parent_taxon
    raise Taxa::InvalidParent.new(self, parent_taxon) unless parent_taxon.is_a?(Subspecies)

    self.subfamily = parent_taxon.subfamily
    self.genus = parent_taxon.genus
    self.subgenus = parent_taxon.subgenus
    self.species = parent_taxon.species
    self.subspecies = parent_taxon
  end

  def update_parent _new_parent
    raise "cannot update parent of infrasubspecies"
  end

  def children
    Taxon.none
  end
end
