# NOTE: This is the superclass of `Genus` and `Subgenus`, not to
# be confused with "genus group" or "genus-group name" as used in taxonomy.

class GenusGroupTaxon < Taxon
  belongs_to :subfamily
  belongs_to :tribe

  def children
    species
  end

  def childrens_rank_in_words
    "species"
  end
end
