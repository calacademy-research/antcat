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

  def self.find_validest_for_epithet_in_genus epithet, genus
    pick_validest find_epithet_in_genus epithet, genus
  end

  def self.pick_validest targets
    return unless targets
    validest = targets.select {|target| target.status == 'valid'}
    if validest.empty?
      validest = targets.select {|target| target.status != 'valid' and target.status != 'homonym'}
    end
    validest.presence
  end

end
