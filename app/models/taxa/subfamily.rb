# frozen_string_literal: true

class Subfamily < Taxon
  belongs_to :family

  with_options dependent: :restrict_with_error do
    has_many :tribes
    has_many :genera
    has_many :species
    has_many :subspecies
  end
  has_many :collective_group_names, -> { where(collective_group_name: true) }, class_name: 'Genus'
  has_many :genera_without_tribe, -> { without_tribe }, class_name: 'Genus'
  # TODO: See note in `Family` regarding incertae sedis.
  has_many :genera_incertae_sedis_in, -> { incertae_sedis_in_subfamily }, class_name: 'Genus'

  def parent
    Family.first
  end

  def parent= parent_taxon
    raise Taxa::InvalidParent.new(self, parent_taxon) unless parent_taxon.is_a?(Family)
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
end
