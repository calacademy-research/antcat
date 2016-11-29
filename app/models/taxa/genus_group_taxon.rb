# Note: This is the superclass of Genus and Subgenus, not to
# be confused with "genus group" as used in taxonomy.

class GenusGroupTaxon < Taxon
  belongs_to :subfamily
  belongs_to :tribe

  def children
    species
  end

  def childrens_rank_in_words
    "species"
  end

  def parent= parent_taxon
    case parent_taxon
    when Subfamily
      self.subfamily = parent_taxon
    when Tribe
      self.subfamily = parent_taxon.subfamily
      self.tribe = parent_taxon
    end
  end
end
