class GenusGroupTaxon < Taxon
  belongs_to :subfamily
  belongs_to :tribe

  # TODO: Probably get rid of all `#children` and `#childrens_rank_in_words` in all classes,
  # or rename (like "direct_children" or "direct_descendants").
  def children
    species
  end

  def childrens_rank_in_words
    "species"
  end
end
