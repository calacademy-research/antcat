class Genus < GenusGroupTaxon
  belongs_to :tribe

  with_options dependent: :restrict_with_error do
    has_many :species
    has_many :subspecies
    has_many :subgenera
  end

  scope :without_subfamily, -> { where(subfamily_id: nil) }
  scope :without_tribe, -> { where(tribe_id: nil) }

  def parent
    tribe || subfamily || Family.first
  end

  def parent= parent_taxon
    case parent_taxon
    when Family, nil
      # NOTE: We don't have to clear `family_id` since we do not store that for genera.
      self.subfamily = nil
      self.tribe = nil
    when Subfamily
      self.subfamily = parent_taxon
      self.tribe = nil
    when Tribe
      self.subfamily = parent_taxon.subfamily
      self.tribe = parent_taxon
    else
      raise Taxa::InvalidParent.new(self, parent_taxon)
    end
  end

  def update_parent new_parent
    self.parent = new_parent
    update_descendants_subfamilies
  end

  def descendants
    Taxon.where(genus: self)
  end

  def species_without_subgenus
    species.without_subgenus
  end

  private

    def update_descendants_subfamilies
      species.each { |s| s.update(subfamily: subfamily) }
      subspecies.each { |s| s.update(subfamily: subfamily) }
      subgenera.each { |s| s.update(subfamily: subfamily) }
    end
end
