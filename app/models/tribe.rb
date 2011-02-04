class Tribe < Taxon
  belongs_to :subfamily
  has_many :genera, :class_name => 'Genus'

  def children
    genera
  end
end
