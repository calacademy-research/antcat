class Species < Taxon
  belongs_to :genus
  has_many :subspecies, :class_name => 'Subspecies', :order => :name

  def children
    subspecies
  end

  def full_name
    "#{genus.subfamily.name} <i>#{genus.name} #{name}</i>"
  end

end
