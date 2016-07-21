class Family < Taxon
  attr_accessible :name, :protonym, :type_name

  def parent
  end

  def parent= parent_taxon
    raise "do you really want to change the parent of Formicidae?"
  end

  def all_displayable_genera
    Genus.displayable.ordered_by_name
  end

  def genera_incertae_sedis_in
    genera.displayable
  end

  def children
    subfamilies
  end

  def genera
    Genus.without_subfamily.ordered_by_name
  end

  def subfamilies
    Subfamily.ordered_by_name
  end

  def statistics
    statistics = {}

    { subfamilies: Subfamily,
      tribes: Tribe,
      genera: Genus,
      species: Species,
      subspecies: Subspecies
    }.each do |rank, klass|
      count = klass.group(:fossil, :status).count
      self.class.massage_count count, rank, statistics
    end

    statistics
  end
end
