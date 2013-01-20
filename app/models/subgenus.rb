# coding: UTF-8
class Subgenus < GenusGroupTaxon
  belongs_to :genus
  validates_presence_of :genus
  has_many :species

  def elevate_to_genus
    new_name_string = name.epithet.to_s
    raise if Genus.find_by_name new_name_string
    new_name = GenusName.find_by_name new_name_string
    new_name ||= GenusName.new
    new_name.update_attributes({
      name:           new_name_string,
      name_html:      Formatters::Formatter.italicize(new_name_string),
      epithet:        name.epithet,
      epithet_html:   name.epithet_html,
      epithets:       nil,
      protonym_html:  Formatters::Formatter.italicize(name.epithet),
    })
    update_attributes! name: new_name
    Subgenus.connection.execute "UPDATE taxa SET type = 'Genus', genus_id = NULL WHERE id = '#{id}'"
    genus = Genus.find id
    genus.set_name_caches
  end

  def species_group_descendants
    Taxon.where(subgenus_id: id).where('taxa.type != ?', 'subgenus').joins(:name).order('names.epithet')
  end

  def self.parent_attributes data, attributes
    super.merge genus: data[:genus]
  end

  def statistics
  end

end
