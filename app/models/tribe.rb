class Tribe < Taxon
  belongs_to :subfamily
  has_many :genera, :class_name => 'Genus', :order => :name

  def children
    genera
  end

  def full_name
    "#{subfamily.name} #{name}"
  end

  def statistics
    {:genera => {'valid' => 2, 'synonym' => 1}}
  end

end
