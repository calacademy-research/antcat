class Subspecies < Taxon
  belongs_to :species
  validates_presence_of :species
end
