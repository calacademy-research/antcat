# coding: UTF-8
class Subspecies < SpeciesGroupTaxon
  belongs_to :species

  def statistics
  end

  def self.import_name data
    name_data = data[:protonym]
    name_data[:genus] = data[:genus]
    name_data[:subspecies_epithet] = data[:species_group_epithet] || data[:species_epithet]
    adjust_species_when_differs_from_protonym name_data, data[:raw_history]
    Name.import name_data
  end

  def self.adjust_species_when_differs_from_protonym name_data, history
    currently_subspecies_of = get_currently_subspecies_of_from_history history
    return unless currently_subspecies_of
    name_data[:subspecies] ||= []
    name_data[:subspecies].unshift subspecies_epithet: name_data[:species_epithet]
    name_data[:species_epithet] = currently_subspecies_of
  end

  def self.after_creating taxon, data
    super
    taxon.create_forward_ref_to_parent_species data
  end

  def create_forward_ref_to_parent_species data
    epithet = self.class.get_currently_subspecies_of_from_history data[:raw_history]
    epithet ||= data[:protonym][:species_epithet]
    SpeciesGroupForwardRef.create!(
      fixee:            self,
      fixee_attribute: 'species',
      genus:            data[:genus],
      epithet:          epithet,
    )
  end

  def self.get_currently_subspecies_of_from_history history
    parent_species = nil
    for item in history or []
      if item[:currently_subspecies_of]
        parent_species = item[:currently_subspecies_of][:species][:species_epithet]
      elsif item[:revived_from_synonymy]
        parent_species = item[:revived_from_synonymy][:subspecies_of].try(:[], :species_epithet)
      end
    end
    parent_species
  end

end
