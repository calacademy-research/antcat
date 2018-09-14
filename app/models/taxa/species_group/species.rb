class Species < SpeciesGroupTaxon
  has_many :subspecies

  def parent
    subgenus || genus
  end

  def parent= parent_taxon
    if parent_taxon.is_a? Subgenus
      self.subgenus = parent_taxon
      self.genus = subgenus.parent
    else
      self.genus = parent_taxon
    end
  end

  def children
    subspecies
  end

  def childrens_rank_in_words
    "subspecies"
  end

  def statistics valid_only: false
    get_statistics [:subspecies], valid_only: valid_only
  end

  def convert_to_subspecies_of species
    Taxa::ConvertToSubspeciesOf[self, species]
  end
end
