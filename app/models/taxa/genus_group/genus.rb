class Genus < GenusGroupTaxon
  attr_accessible :current_valid_taxon, :current_valid_taxon_id,
    :homonym_replaced_by, :name, :protonym, :subfamily, :tribe, :type_name

  belongs_to :tribe

  has_many :species
  has_many :subspecies
  has_many :subgenera

  scope :without_subfamily, -> { where(subfamily_id: nil) }
  scope :without_tribe, -> { where(tribe_id: nil) }

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

  def statistics valid_only: false
    get_statistics [:species, :subspecies], valid_only: valid_only
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

  def find_epithet_in_genus target_epithet_string
    Names::EpithetSearchSet[target_epithet_string].each do |epithet|
      results = Taxon.joins(:name).where(genus: self)
        .where("names.epithet = ?", epithet)
      return results unless results.empty?
    end
    nil
  end

  # TODO this is the same as `#find_epithet_in_genus`.
  # Found this in the git history:
  # results = with_names.where(['genus_id = ? AND epithet = ? and type="SubspeciesName"', genus.id, epithet])
  def find_subspecies_in_genus target_subspecies_string
    Names::EpithetSearchSet[target_subspecies_string].each do |epithet|
      results = Taxon.joins(:name).where(genus: self)
        .where("names.epithet = ?", epithet)
      return results unless results.empty?
    end
    nil
  end

  private
    def update_descendants_subfamilies
      species.each { |s| s.subfamily = subfamily }
      subspecies.each { |s| s.subfamily = subfamily }
    end
end
