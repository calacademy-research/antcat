# coding: UTF-8
class Genus < GenusGroupTaxon
  belongs_to :tribe
  has_many :species
  has_many :subspecies
  has_many :subgenera

  scope :without_subfamily, where(subfamily_id: nil)
  scope :without_tribe, where(tribe_id: nil)

  def statistics
    get_statistics [:species, :subspecies]
  end

  def siblings
    tribe && tribe.genera.ordered_by_name ||
    subfamily && subfamily.genera.without_tribe.ordered_by_name ||
    Genus.without_subfamily.ordered_by_name
  end

  def self.import data
    super data, :genus_name, subfamily: data[:subfamily], tribe: data[:tribe]
  end

end
