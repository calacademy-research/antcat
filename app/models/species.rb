# coding: UTF-8
class Species < SpeciesGroupTaxon
  has_many :subspecies

  def siblings
    genus.species
  end

end
