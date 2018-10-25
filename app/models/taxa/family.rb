class Family < Taxon
  def parent
  end

  def parent= _parent_taxon
    raise "cannot update parent of families"
  end

  def update_parent _new_parent
    raise "cannot update parent of families"
  end

  def children
    subfamilies
  end

  def childrens_rank_in_words
    "subfamilies"
  end

  def all_displayable_genera
    Genus.displayable
  end

  def genera_incertae_sedis_in
    genera.displayable
  end

  def genera
    Genus.without_subfamily
  end

  def subfamilies
    Subfamily.all
  end

  def statistics valid_only: false
    ranks = {
      subfamilies: Subfamily,
      tribes: Tribe,
      genera: Genus,
      species: Species,
      subspecies: Subspecies
    }
    get_statistics ranks, valid_only: valid_only
  end
end
