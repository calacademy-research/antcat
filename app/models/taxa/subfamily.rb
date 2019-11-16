class Subfamily < Taxon
  belongs_to :family

  has_many :tribes
  has_many :genera
  has_many :species
  has_many :subspecies
  has_many :collective_group_names, -> { where(collective_group_name: true) }, class_name: 'Genus'

  def parent
    Family.first
  end

  def parent= parent_taxon
    raise InvalidParent.new(self, parent_taxon) unless parent_taxon.is_a?(Family)
    self.family = parent_taxon
  end

  def update_parent _new_parent
    raise "cannot update parent of subfamilies"
  end

  # TODO: This does not include incertae sedis taxa (genera in this case).
  def children
    tribes
  end

  def childrens_rank_in_words
    "tribes"
  end

  # TODO: See note in `Family` regarding incertae sedis.
  def genera_incertae_sedis_in
    genera.where(incertae_sedis_in: INCERTAE_SEDIS_IN_SUBFAMILY)
  end

  def genera_without_tribe
    genera.without_tribe
  end
end
