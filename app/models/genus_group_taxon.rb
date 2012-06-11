# coding: UTF-8
class GenusGroupTaxon < Taxon
  belongs_to :subfamily
  belongs_to :tribe

  def children
    species
  end

  def full_label
    "<i>#{full_name}</i>"
  end

end
