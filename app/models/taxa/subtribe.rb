# frozen_string_literal: true

class Subtribe < Taxon
  belongs_to :subfamily
  belongs_to :tribe

  validates :subfamily, :tribe, presence: true

  def parent
    tribe
  end

  def parent= _parent_taxon
    raise "cannot update parent of subtribes"
  end

  def update_parent _new_parent
    raise "cannot update parent of subtribes"
  end
end
