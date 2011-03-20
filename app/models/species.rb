class Species < Taxon
  belongs_to :genus
  has_many :subspecies, :class_name => 'Subspecies', :order => :name

  def children
    subspecies
  end

end
