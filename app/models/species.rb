class Species < Taxon
  belongs_to :subfamily
  belongs_to :genus
  has_many :subspecies, :class_name => 'Subspecies', :order => :name
  before_create :set_subfamily

  def set_subfamily
    self.subfamily = genus.subfamily if genus
  end

  def children
    subspecies
  end

  def full_name
    "<i>#{genus.name} #{name}</i>"
  end

  def statistics include_fossil = true
    {:subspecies => include_fossil ? subspecies.count(:group => :status) : subspecies.extant.count(:group => :status)}
  end

  def siblings
    genus.species
  end

end
