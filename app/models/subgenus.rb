class Subgenus < Taxon
  belongs_to :genus
  has_many :species, :class_name => 'Species', :order => :name
  validates_presence_of :genus

  def children
    species
  end

  def statistics
    {:genera => {'valid' => 2, 'synonym' => 1}}
  end

end
