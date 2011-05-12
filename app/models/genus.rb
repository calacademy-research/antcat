class Genus < Taxon
  belongs_to :tribe
  belongs_to :subfamily
  has_many :species, :class_name => 'Species', :order => :name
  has_many :subspecies, :class_name => 'Subspecies', :order => :name
  has_many :subgenera, :class_name => 'Subgenus', :order => :name

  scope :without_subfamily, where(:subfamily_id => nil)

  def children
    species
  end

  def full_name
    "<i>#{name}</i>"
  end

  def statistics
    {:species => species.count(:group => :status),
     :subspecies => subspecies.count(:group => :status),
    }
  end

end
