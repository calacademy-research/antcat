# coding: UTF-8
class Species < SpeciesGroupTaxon
  has_many :subspecies

  def siblings
    genus.species
  end

  def children
    subspecies
  end

  def statistics
    get_statistics [:subspecies]
  end

end
