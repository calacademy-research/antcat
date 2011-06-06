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

  def statistics include_fossil = true
    {:genera => include_fossil ? genera.count(:group => :status) : genera.extant.count(:group => :status),
     :species => include_fossil ? species.count(:group => :status) : species.extant.count(:group => :status),
     :subspecies => include_fossil ? subspecies.count(:group => :status) : subspecies.extant.count(:group => :status),
    }
  end

end
