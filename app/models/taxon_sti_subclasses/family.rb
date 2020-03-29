# frozen_string_literal: true

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

  # TODO: See https://github.com/calacademy-research/antcat/issues/453
  # See also `ChildList` and `Subfamily`.
  def genera_incertae_sedis_in
    Genus.incertae_sedis_in_family
  end

  def subfamilies
    Subfamily.all
  end

  # TODO: See what do to with these `Taxon.all` methods; added for `FetchStatistics`.
  def tribes
    Tribe.all
  end

  def genera
    Genus.all
  end

  def species
    Species.all
  end
end
