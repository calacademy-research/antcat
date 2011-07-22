class Subfamily < Taxon
  has_many :tribes, :order => :name
  has_many :genera, :class_name => 'Genus', :order => :name
  has_many :species, :class_name => 'Species', :order => :name
  has_many :subspecies, :class_name => 'Subspecies', :order => :name

  def children
    tribes
  end

  def full_name
    name
  end

  def full_label
    full_name
  end

  def statistics
    get_statistics [:genera, :species, :subspecies]
  end

end
