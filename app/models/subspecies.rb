# coding: UTF-8
class Subspecies < SpeciesGroupTaxon
  belongs_to :species

  def statistics
  end

  def self.import_name data
    Name.import data[:protonym].merge genus: data[:genus]
  end

  def do_stuff_after_creating_taxon data
    super
    create_forward_ref_to_parent_species data
  end

  def create_forward_ref_to_parent_species data
    target_epithet = self.class.get_currently_subspecies_of_from_history data[:raw_history]
    target_epithet ||= data[:protonym][:species_epithet]
    SpeciesForwardRef.create!(
      fixee:            self,
      fixee_attribute: 'species_id',
      genus:            data[:genus],
      epithet:          target_epithet,
    )
  end

  def self.get_currently_subspecies_of_from_history history
    for item in history or []
      if item[:currently_subspecies_of]
        return item[:currently_subspecies_of][:species][:species_epithet]
      end
    end
    nil
  end

end
