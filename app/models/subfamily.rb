class Subfamily < Taxon
  has_many :tribes, :order => :name
  has_many :genera, :class_name => 'Genus', :order => :name

  def children
    tribes
  end

  def full_name
    name
  end

end
