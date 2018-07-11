class Subfamily < Taxon
  belongs_to :family

  has_many :tribes
  has_many :genera
  has_many :species
  has_many :subspecies
  has_many :collective_group_names, -> { where(status: Status::COLLECTIVE_GROUP_NAME) },
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

  def childrens_rank_in_words
    "tribes"
  end

  def statistics valid_only: false
    get_statistics [:tribes, :genera, :species, :subspecies], valid_only: valid_only
  end

  def all_displayable_genera
    genera.displayable
  end

  def genera_incertae_sedis_in
    genera.displayable.without_tribe
  end
end
