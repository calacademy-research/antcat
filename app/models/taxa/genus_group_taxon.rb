class GenusGroupTaxon < Taxon
  include Formatters::RefactorFormatter

  belongs_to :subfamily
  belongs_to :tribe

  def children
    species
  end

  def label
    italicize name
  end

  def parent= id_or_object
    parent_taxon = id_or_object.kind_of?(Taxon) ? id_or_object : Taxon.find(id_or_object)
    if parent_taxon.kind_of? Subfamily
      self.subfamily = parent_taxon
    elsif parent_taxon.kind_of? Tribe
      self.subfamily = parent_taxon.subfamily
      self.tribe = parent_taxon
    end
  end

  def parent
    if self.is_a? Subgenus
      return genus
    end
    tribe || subfamily
  end

end
