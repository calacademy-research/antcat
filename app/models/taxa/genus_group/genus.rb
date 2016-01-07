class Genus < GenusGroupTaxon
  belongs_to :tribe
  has_many :species
  has_many :subspecies
  has_many :subgenera

  scope :without_subfamily, -> { where(subfamily_id: nil) }
  scope :without_tribe, -> { where(tribe_id: nil) }
  attr_accessible :name,
                  :protonym,
                  :subfamily,
                  :tribe,
                  :type_name,
                  :current_valid_taxon_id,
                  :current_valid_taxon,
                  :homonym_replaced_by

  def update_parent new_parent
    set_name_caches
    case
    when new_parent.kind_of?(Tribe)
      self.tribe = new_parent
      self.subfamily = new_parent.subfamily
    when new_parent.kind_of?(Subfamily)
      self.tribe = nil
      self.subfamily = new_parent
    when new_parent.nil?
      self.tribe = nil
      self.subfamily = nil
    end
    update_descendants_subfamilies
  end

  def statistics
    get_statistics [:species, :subspecies]
  end

  def siblings
    tribe && tribe.genera.ordered_by_name ||
    subfamily && subfamily.genera.without_tribe.ordered_by_name ||
    Genus.without_subfamily.ordered_by_name
  end

  def species_group_descendants
    Taxon.where(genus_id: id).where('taxa.type != ?', 'subgenus').includes(:name).order('names.epithet')
  end

  def add_antweb_attributes attributes
    subfamily_name = subfamily && subfamily.name.to_s || 'incertae_sedis'
    tribe_name = tribe && tribe.name.to_s
    attributes.merge subfamily: subfamily_name, tribe: tribe_name, genus: name.to_s
  end

  private
    def update_descendants_subfamilies
      self.species.each{ |s| s.subfamily = self.subfamily }
      self.subspecies.each{ |s| s.subfamily = self.subfamily }
    end

end