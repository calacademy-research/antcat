# Note: This is the superclass of Genus and Subgenus, not to
# be confused with "genus group" as used in taxonomy.

class GenusGroupTaxon < Taxon
  include Formatters::ItalicsHelper

  belongs_to :subfamily
  belongs_to :tribe

  def children
    species
  end

  def label
    italicize name
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
