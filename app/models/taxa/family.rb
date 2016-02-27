class Family < Taxon
  attr_accessible :name,:protonym,:type_name

  def parent
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
    get_statistics Subfamily, Tribe, Genus, Species, Subspecies
  end

  private
    def get_statistics *ranks
      ranks.inject({}) do |statistics, klass|
        count = klass.group(:fossil,:status).count
        self.class.massage_count count, Rank[klass].plural.to_sym, statistics
        statistics
      end
    end
end
