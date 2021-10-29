# frozen_string_literal: true

class Subfamily < Taxon
  belongs_to :family, optional: true

  with_options dependent: :restrict_with_error do
    has_many :tribes
    has_many :genera
    has_many :species
    has_many :subspecies
  end
  has_many :collective_group_names, -> { where(collective_group_name: true) }, class_name: Rank::GENUS
  has_many :genera_without_tribe, -> { without_tribe }, class_name: Rank::GENUS
  # TODO: See note in `Family` regarding incertae sedis.
  has_many :genera_incertae_sedis_in, -> { incertae_sedis_in_subfamily }, class_name: Rank::GENUS

  validates(*(TAXA_COLUMNS - [:family_id]), absence: true)

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

  def immediate_children
    tribes
  end

  def immediate_children_rank
    "tribes"
  end
end
