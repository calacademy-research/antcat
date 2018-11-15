class Genus < GenusGroupTaxon
  belongs_to :tribe

  has_many :species
  has_many :subspecies
  has_many :subgenera

  scope :without_subfamily, -> { where(subfamily_id: nil) }
  scope :without_tribe, -> { where(tribe_id: nil) }

  def parent
    tribe || subfamily || Family.first
  end

  def parent= parent_taxon
    case parent_taxon
    when Subfamily
      self.subfamily = parent_taxon
      self.tribe = nil
    when Tribe
      self.subfamily = parent_taxon.subfamily
      self.tribe = parent_taxon
    else
      raise InvalidParent.new(self, parent_taxon)
    end
  end

  def update_parent new_parent
    self.parent = new_parent
    update_descendants_subfamilies
  end

  def displayable_child_taxa
    descendants.displayable
  end

  def displayable_subgenera
    Subgenus.where(genus: self).displayable
  end

  def descendants
    Taxon.where(genus: self)
  end

  def find_epithet_in_genus target_epithet_string
    Taxon.joins(:name).where(genus: self).
      where(names: { epithet: Names::EpithetSearchSet[target_epithet_string] })
  end

  # TODO this is the same as `#find_epithet_in_genus`.
  # Found this in the git history:
  # results = with_names.where(['genus_id = ? AND epithet = ? and type="SubspeciesName"', genus.id, epithet])
  def find_subspecies_in_genus target_subspecies_string
    Taxon.joins(:name).where(genus: self).
      where(names: { epithet: Names::EpithetSearchSet[target_subspecies_string] })
  end

  private

    def update_descendants_subfamilies
      species.each { |s| s.subfamily = subfamily }
      subspecies.each { |s| s.subfamily = subfamily }
      subgenera.each { |s| s.subfamily = subfamily }
    end
end
