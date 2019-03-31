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

  def all_displayable_genera
    genera.displayable
  end

  def genera_incertae_sedis_in
    genera.displayable.without_tribe
  end
end
