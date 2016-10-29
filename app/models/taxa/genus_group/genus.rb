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
    case new_parent
    when Tribe
      self.tribe = new_parent
      self.subfamily = new_parent.subfamily
    when Subfamily
      self.tribe = nil
      self.subfamily = new_parent
    when nil
      self.tribe = nil
      self.subfamily = nil
    end
    update_descendants_subfamilies
  end

  def statistics
    get_statistics [:species, :subspecies]
  end

  def parent
    tribe || subfamily || Family.first
  end

  def siblings
    tribe && tribe.genera ||
    subfamily && subfamily.genera.without_tribe ||
    Genus.without_subfamily
  end

  def displayable_child_taxa
    descendants.displayable
  end

  def descendants
    Taxon.where(genus: self)
  end

  def displayable_subgenera
    Subgenus.where(genus: self).displayable
  end

  private
    def update_descendants_subfamilies
      self.species.each { |s| s.subfamily = self.subfamily }
      self.subspecies.each { |s| s.subfamily = self.subfamily }
    end
end
