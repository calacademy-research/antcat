class Subspecies < SpeciesGroupTaxon
  include Formatters::RefactorFormatter
  include UndoTracker

  class NoSpeciesForSubspeciesError < StandardError; end

  belongs_to :species
  before_validation :set_genus
  attr_accessible :subfamily, :genus, :name, :protonym, :species, :type, :type_name_id
  has_paper_trail meta: { change_id: :get_current_change_id }

  def update_parent new_parent
    # TODO Joe - somewhere, we need to check and pop up for the homonym case if there are multiple possibles.
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

  def children
    Subspecies.none
  end

  # This possibly should go through taxon_mother. It's a taxon change, after all,
  # and the others are handled there.
  def elevate_to_species
    raise NoSpeciesForSubspeciesError unless species
    # Removed commented out code that looked very WIP

    new_name_string = "#{species.genus.name} #{name.epithet}"
    new_name = SpeciesName.find_by_name new_name_string
    unless new_name
      new_name = SpeciesName.new
      new_name.update_attributes name: new_name_string,
                                 name_html: italicize(new_name_string),
                                 epithet: name.epithet,
                                 epithet_html: name.epithet_html,
                                 epithets: nil
      new_name.save
    end

    # writes directly to db, bypasses save. "update_attributes" operates in memory and
    # lets you use the "save" path
    self.update_columns name_id: new_name.id,
                        species_id: nil,
                        name_cache: new_name.name,
                        name_html_cache: new_name.name_html,
                        type: 'Species'
  end
end
