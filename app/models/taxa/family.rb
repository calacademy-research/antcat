class Family < Taxon
  attr_accessible :name,:protonym,:type_name

  def parent; end

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
        self.class.massage_count count, Rank[klass].to_sym(:plural), statistics
        statistics
      end
    end
end
