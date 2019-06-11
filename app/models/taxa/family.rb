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

  # TODO: For this, `#genera` and `#genera_incertae_sedis_in_family`, see ihttps://github.com/calacademy-research/antcat/issues/453
  # See also `TaxonDecorator::ChildList`.
  def genera_incertae_sedis_in
    genera.displayable
  end

  def genera_incertae_sedis_in_family
    Genus.where(incertae_sedis_in: 'family')
  end

  def genera
    Genus.without_subfamily
  end

  def subfamilies
    Subfamily.all
  end
end
