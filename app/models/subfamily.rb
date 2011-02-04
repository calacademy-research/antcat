class Subfamily < Taxon
  has_many :tribes
  has_many :genera, :class_name => 'Genus'

  def children
    tribes
  end
end
