# coding: UTF-8
class Subgenus < GenusGroupTaxon
  belongs_to :genus
  validates_presence_of :genus
  has_many :species
  attr_accessible :subfamily, :tribe, :genus, :homonym_replaced_by

  def species_group_descendants
    Taxon.where(subgenus_id: id).where('taxa.type != ?', 'subgenus').includes(:name).order('names.epithet')
  end

  def self.parent_attributes data, attributes
    super.merge genus: data[:genus]
  end

  def statistics
  end

  def add_antweb_attributes attributes
    subfamily_name = subfamily && subfamily.name.to_s || 'incertae_sedis'
    genus_name = genus && genus.name.to_s
    attributes.merge subfamily: subfamily_name, genus: genus_name, subgenus: name.epithet.gsub(/[\(\)]/,'')
  end

end