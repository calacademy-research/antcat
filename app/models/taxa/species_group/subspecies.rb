# coding: UTF-8
class Subspecies < SpeciesGroupTaxon
  include Formatters::RefactorFormatter
  include UndoTracker

  class NoSpeciesForSubspeciesError < StandardError; end

  belongs_to :species
  before_validation :set_genus
  attr_accessible :subfamily, :genus, :name, :protonym, :species, :type, :type_name_id
  has_paper_trail meta: { change_id: :get_current_change_id }

  def update_parent new_parent
    # Joe - somewhere, we need to check and pop up for the homonym case if there are multiple possibles.
    super
    if defined? new_parent.genus
      self.genus = new_parent.genus
    end
    if defined? new_parent.subgenus
      self.subgenus = new_parent.subgenus
    end
    self.species = new_parent
  end

  def set_genus
    self.genus = species.genus if species and not genus
  end

  def statistics; end

  def parent
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

    new_name_string = "#{species.genus.name} #{name.epithet}"
    new_name = SpeciesName.find_by_name new_name_string
    unless new_name
      new_name = SpeciesName.new
      new_name.update_attributes({
                                    name: new_name_string,
                                    name_html: italicize(new_name_string),
                                    epithet: name.epithet,
                                    epithet_html: name.epithet_html,
                                    epithets: nil
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

  def add_antweb_attributes attributes
    subfamily_name = genus.subfamily && genus.subfamily.name.to_s || 'incertae_sedis'
    tribe_name = genus.tribe && genus.tribe.name.to_s
    #species_name = species && species.name.epithet
    #attributes.merge subfamily: subfamily_name, tribe: tribe_name, genus: genus.name.to_s, species: species_name, subspecies: name.epithet

    case name.type
    when 'SubspeciesName'
      attributes.merge! genus: genus.name.to_s,
        species: name.epithets.split(' ').first, subspecies: name.epithet
    when 'SpeciesName'
      attributes.merge! genus: name.to_s.split(' ').first, species: name.epithet
    else
      attributes.merge! genus: genus.name.to_s, species: name.epithet
    end

    # attributes.merge subfamily: subfamily_name, tribe: tribe_name, genus: genus.name.to_s
    attributes.merge subfamily: subfamily_name, tribe: tribe_name
  end

end
