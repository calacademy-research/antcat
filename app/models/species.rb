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

  def statistics
    {:subspecies => subspecies.count(:group => :status) }
  end

end
