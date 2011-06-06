class Genus < Taxon
  belongs_to :tribe
  belongs_to :subfamily
  has_many :species, :class_name => 'Species', :order => :name
  has_many :subspecies, :class_name => 'Subspecies', :order => :name
  has_many :subgenera, :class_name => 'Subgenus', :order => :name

  scope :without_subfamily, where(:subfamily_id => nil)
  scope :without_tribe, where(:tribe_id => nil)

  def children
    species
  end

  def full_name
    "<i>#{name}</i>"
  end

  def statistics include_fossil = true
    {:species => include_fossil ? species.count(:group => :status) : species.extant.count(:group => :status),
     :subspecies => include_fossil ? subspecies.count(:group => :status) : subspecies.extant.count(:group => :status)}
  end

  def siblings
    tribe && tribe.genera ||
    subfamily && subfamily.genera.without_tribe.all ||
    Genus.without_subfamily.all
  end

end
