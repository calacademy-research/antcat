class Tribe < Taxon
  belongs_to :subfamily
  has_many :genera, :class_name => 'Genus', :order => :name

  def children
    genera
  end
end
