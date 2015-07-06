# coding: UTF-8
class Subspecies < SpeciesGroupTaxon
  include Formatters::Formatter
  include UndoTracker

  belongs_to :species
  before_validation :set_genus
  attr_accessible :subfamily, :genus, :name, :protonym, :species, :type, :type_name_id
  has_paper_trail meta: {change_id: :get_current_change_id}

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

  def parent
    # Rubyism; a || b of two valid objects returns a. Order dependent.
    species || genus
  end

  # This possibly should go through taxon_mother. It's a taxon change, after all,
  # and the others are handled there.
  def elevate_to_species
    raise NoSpeciesForSubspeciesError unless species

    # to add support for change/undo (commented out here)
    # There are two issues with this;
    # #1: in taxon_mother, save invokes "build_children", which calls
    #     @taxon.build_type_name unless @taxon.type_name. This populates
    # type_name_id, which breaks display. I haven't root caused the purpose of
    # type_name_id, so won't take unilateral action.
    #
    # #2: paper_trail can't save the "type" field. This is likely because
    # it's linked to object-ness in activerecord (when you instate an object, this is how rails
    # knows what type it is). doing an "undo" cauases everything to revert except for
    # the type field. Fix unclear.
    #
    # possible workarounds: Disable "undo" and show the change so it can be approved.
    # hack the paper_Trail version record to manually add the "type" field.
    # Root cause how paper trail treats "types".
    # #3 is the only real option. I did some of this but it was a rat-hole.

    # Do monkey-see-monkey-do in species.rb become_species_of for orthogonal features.


    # change = Change.new
    # change.change_type = :update
    # change.user_changed_taxon_id = self.id
    # change.save!
    # RequestStore.store[:current_change_id] = change.id

    new_name_string = species.genus.name.to_s + ' ' + name.epithet
    new_name = SpeciesName.find_by_name new_name_string
    if new_name.nil?
      new_name = SpeciesName.new
      new_name.update_attributes({
                                     name: new_name_string,
                                     name_html: italicize(new_name_string),
                                     epithet: name.epithet,
                                     epithet_html: name.epithet_html,
                                     epithets: nil,
                                     protonym_html: name.protonym_html,
                                 })
      new_name.save
    end

    # writes directly to db, bypasses save. "update_attributes" operates in memory and
    # lets you use the "save" path
    self.update_columns name_id: new_name.id,
                           species_id: nil,
                           name_cache: new_name.name,
                           name_html_cache: new_name.name_html,
                           type: 'Species'
    # ts = self.taxon_state
    # ts.review_state = :waiting
    # ts.save

    #self.save!(:validate => false)

    # clear_change
  end

  def fix_missing_species
    return if species
    epithet = name.epithets.split(' ').first
    results = Species.find_epithet_in_genus epithet, genus
    return unless results
    self.species = results.first
    save!
  end

  def self.fix_missing_species;
    all.each { |e| e.fix_missing_species }
  end

  def add_antweb_attributes attributes
    subfamily_name = genus.subfamily && genus.subfamily.name.to_s || 'incertae_sedis'
    tribe_name = genus.tribe && genus.tribe.name.to_s
    #species_name = species && species.name.epithet
    #attributes.merge subfamily: subfamily_name, tribe: tribe_name, genus: genus.name.to_s, species: species_name, subspecies: name.epithet


    if name.type == 'SubspeciesName'
      attributes.merge! genus: genus.name.to_s, species: name.epithets.split(' ').first, subspecies: name.epithet
    elsif name.type == 'SpeciesName'
      attributes.merge! genus: name.to_s.split(' ').first, species: name.epithet
    else
      attributes.merge! genus: genus.name.to_s, species: name.epithet
    end


    # attributes.merge subfamily: subfamily_name, tribe: tribe_name, genus: genus.name.to_s
    attributes.merge subfamily: subfamily_name, tribe: tribe_name

  end

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
        fixee: self,
        fixee_attribute: 'species',
        genus: data[:genus],
        epithet: epithet,
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

  class NoSpeciesForSubspeciesError < StandardError;
  end

end
