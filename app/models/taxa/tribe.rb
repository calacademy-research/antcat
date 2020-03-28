# frozen_string_literal: true

class Tribe < Taxon
  belongs_to :subfamily

  with_options dependent: :restrict_with_error do
    has_many :subtribes
    has_many :genera
    has_many :species, through: :genera
  end

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

  def children
    genera
  end

  def childrens_rank_in_words
    "genera"
  end
end
