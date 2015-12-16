# coding: UTF-8
class Family < Taxon
  attr_accessible :name,:protonym,:type_name

  def genera
    Genus.without_subfamily.ordered_by_name
  end

  def subfamilies
    Subfamily.ordered_by_name
  end

  def statistics
    get_statistics Subfamily, Tribe, Genus, Species, Subspecies
  end

  def get_statistics *ranks
    ranks.inject({}) do |statistics, klass|
      count = klass.group(:fossil,:status).count
      self.class.massage_count count, Rank[klass].to_sym(:plural), statistics
      statistics
    end
  end

  def add_antweb_attributes attributes
    attributes.merge subfamily: 'Formicidae'
  end
end
