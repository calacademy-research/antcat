# coding: UTF-8
class Subspecies < SpeciesGroupTaxon
  belongs_to :species
  before_validation :set_genus

  def update_parent new_parent
    super
    self.genus = new_parent.genus
    self.subgenus = new_parent.subgenus
  end

  def set_genus
    self.genus = species.genus if species and not genus
  end

  def statistics
  end

  def elevate_to_species
    raise NoSpeciesForSubspeciesError unless species

    new_name_string = species.genus.name.to_s + ' ' + name.epithet
    raise if Species.find_by_name new_name_string
    new_name = SpeciesName.find_by_name new_name_string
    new_name ||= SpeciesName.new
    new_name.update_attributes({
      name:           new_name_string,
      name_html:      italicize(new_name_string),
      epithet:        name.epithet,
      epithet_html:   name.epithet_html,
      epithets:       nil,
      protonym_html:  name.protonym_html,
    })
    update_attributes name: new_name, species: nil
    Subspecies.connection.execute "UPDATE taxa SET type = 'Species' WHERE id = '#{id}'"
  end

  def fix_missing_species
    return if species
    epithet = name.epithets.split(' ').first
    results = Species.find_epithet_in_genus epithet, genus
    return unless results
    self.species = results.first
    save!
  end
  def self.fix_missing_species; all.each {|e| e.fix_missing_species} end

  ############################
  # import

  def self.import_name data
    name_data = data[:protonym].dup
    name_data[:genus] = data[:genus]
    name_data[:subspecies_epithet] = data[:species_group_epithet] || data[:species_epithet]
    adjust_species_when_differs_from_protonym name_data, data[:raw_history]
    Name.import name_data
  end

  def self.adjust_species_when_differs_from_protonym name_data, history
    currently_subspecies_of = get_currently_subspecies_of_from_history history
    return unless currently_subspecies_of
    name_data[:subspecies] ||= [subspecies_epithet: name_data[:species_epithet]]
    name_data[:species_epithet] = currently_subspecies_of
  end

  def self.after_creating taxon, data
    super
    taxon.link_to_or_delete_parent_species data
  end

  def link_to_or_delete_parent_species data
    species = Species.find_by_name genus.name.name + ' ' + name.epithet
    if species and species.subspecies.count.zero?
      Update.create! name: species.name.name, class_name: self.class.to_s, record_id: species.id, field_name: 'delete',
        before: nil, after: nil
      species.destroy
    else
      create_forward_ref_to_parent_species data
    end
  end

  def self.after_updating taxon, data
    super
    taxon.create_forward_ref_to_parent_species data
  end

  def create_forward_ref_to_parent_species data
    epithet = self.class.get_currently_subspecies_of_from_history data[:raw_history]
    epithet ||= data[:protonym][:species_epithet]
    ForwardRefToParentSpecies.create!(
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

  class NoSpeciesForSubspeciesError < StandardError; end

end
