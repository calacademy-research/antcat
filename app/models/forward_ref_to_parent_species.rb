# coding: UTF-8
class ForwardRefToParentSpecies < SpeciesGroupForwardRef

  def fixup
    specieses = SpeciesGroupTaxon.find_validest_for_epithet_in_genus epithet, genus
    if specieses.blank?
      Progress.error "Couldn't find species #{epithet} in genus #{genus.name} when fixing up species for #{fixee.inspect}"
    elsif specieses.count > 1
      Progress.error "Found multiple valid targets among #{specieses.map(&:name).map(&:to_s).join(', ')}"
    else
      species = specieses.first
      species = species.species if species.respond_to? :species
      fixee.update_attributes fixee_attribute.to_sym => species
    end
  end

end
