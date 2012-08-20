# coding: UTF-8
class ForwardRefToSeniorSynonym < SpeciesGroupForwardRef

  def fixup
    specieses = SpeciesGroupTaxon.find_validest_for_epithet_in_genus epithet, genus
    if specieses.blank?
      unless we_dont_care_about? epithet, genus
        Progress.error "Couldn't find species #{epithet} in genus #{genus.name} when fixing up senior synonym of #{fixee.junior_synonym.inspect}"
      end
    elsif specieses.count > 1
      Progress.error "Found multiple valid targets among #{specieses.map(&:name).map(&:to_s).join(', ')}"
    else
      species = specieses.first
      fixee.update_attributes fixee_attribute.to_sym => species
    end
  end

  def we_dont_care_about? genus, epithet
    genus == 'Leptothorax'
  end

end
