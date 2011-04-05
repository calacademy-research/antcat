class Subspecies < Taxon
  belongs_to :species
  validates_presence_of :species

  def full_name
    "#{species.genus.subfamily.name} <i>#{species.genus.name} #{species.name} #{name}</i>"
  end

end
