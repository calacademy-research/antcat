# coding: UTF-8
class ForwardRefToParentSpecies < SpeciesGroupForwardRef

  def fixup
    specieses = SpeciesGroupTaxon.find_validest_for_epithet_in_genus epithet, genus
    if specieses.blank?
      Progress.error "Couldn't find species #{epithet} in genus #{genus.name} when fixing up parent species for #{fixee.name}"
    elsif specieses.count > 1
      Progress.error "Found multiple valid targets for parent species among #{specieses.map(&:name).map(&:to_s).join(', ')}"
    else
      species = specieses.first
      return if species.kind_of? Subspecies
      fixee.update_attribute fixee_attribute.to_sym, species
      if epithet != species.name.epithet
        for field in [:name, :name_html, :epithet, :epithet_html, :epithets]
          fixee.name.update_attribute field, fixee.name[field].gsub(/\b#{epithet}\b/, species.name.epithet)
        end
      end
    end
  end

end
