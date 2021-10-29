# frozen_string_literal: true

class Tribe < Taxon
  belongs_to :subfamily

  with_options dependent: :restrict_with_error do
    has_many :subtribes
    has_many :genera
    has_many :species, through: :genera
  end

  validates(*(TAXA_COLUMNS - [:subfamily_id]), absence: true)

  def parent
    subfamily
  end

  def parent= parent_taxon
    raise Taxa::InvalidParent.new(self, parent_taxon) unless parent_taxon.is_a?(Subfamily)
    self.subfamily = parent_taxon
  end

  def update_parent _new_parent
    raise "cannot update parent of tribes"
  end

  def immediate_children
    genera
  end

  def immediate_children_rank
    "genera"
  end
end
