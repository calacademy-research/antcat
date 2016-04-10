class Subfamily < Taxon
  belongs_to :family
  has_many :tribes
  has_many :genera
  has_many :species
  has_many :subspecies
  has_many :collective_group_names,
           -> { where(status: 'collective group name') },
            class_name: 'Genus'

  def parent
    Family.first
  end

  def parent= parent_taxon
    self.family = parent_taxon
  end

  # TODO among other things, this is called when deleting a
  # taxon + its children, and in that case it fails to take into
  # account incertae sedis taxa (genera in this case).
  def children
    tribes
  end

  def statistics
    get_statistics [:tribes, :genera, :species, :subspecies]
  end

  def all_displayable_genera
    genera.displayable.ordered_by_name
  end

  def genera_incertae_sedis_in
    genera.displayable.without_tribe.ordered_by_name
  end
end
