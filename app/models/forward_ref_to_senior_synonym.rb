# coding: UTF-8
class ForwardRefToSeniorSynonym < SpeciesGroupForwardRef

  def fixup
    species = self.class.find_species_for_fixup genus, epithet, fixee.junior_synonym.name.name
    fixee.update_attributes fixee_attribute.to_sym => species
  end

  def self.find_species_for_fixup genus, epithet, name
    specieses = SpeciesGroupTaxon.find_validest_for_epithet_in_genus epithet, genus
    if specieses.blank?
      unless we_dont_care_about? epithet, genus
        Progress.error "Couldn't find species #{epithet} in genus #{genus.name} when fixing up senior synonym of #{name}"
      end
    elsif specieses.count > 1
      Progress.error "Found multiple valid targets among senior synonyms #{specieses.map(&:name).map(&:to_s).join(', ')}"
    else
      species = specieses.first
    end
  end

  def self.we_dont_care_about? genus, epithet
    genus == 'Leptothorax'
  end

end
