class Family < Taxon
  def parent
  end

  def parent= _parent_taxon
    raise "do you really want to change the parent of Formicidae?"
  end

  def all_displayable_genera
    Genus.displayable
  end

  def genera_incertae_sedis_in
    genera.displayable
  end

  def children
    subfamilies
  end

  def childrens_rank_in_words
    "subfamilies"
  end

  def genera
    Genus.without_subfamily
  end

  def subfamilies
    Subfamily.all
  end

  def statistics valid_only: false
    statistics = {}

    { subfamilies: Subfamily,
      tribes: Tribe,
      genera: Genus,
      species: Species,
      subspecies: Subspecies
    }.each do |rank, klass|
      count = if valid_only
                klass.valid
              else
                klass
              end.group(:fossil, :status).count
      self.class.massage_count count, rank, statistics
    end

    statistics
  end
end
