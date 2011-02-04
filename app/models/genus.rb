class Genus < Taxon
  belongs_to :tribe
  belongs_to :subfamily
  has_many :species, :class_name => 'Species'

  def children
    species
  end
end
