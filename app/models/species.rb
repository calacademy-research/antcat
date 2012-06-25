# coding: UTF-8
class Species < SpeciesGroupTaxon
  has_many :subspecies

  def siblings
    genus.species
  end

  def self.import_name data
    Name.import data
  end

end
