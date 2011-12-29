# coding: UTF-8
class Genus < Taxon
  belongs_to :tribe
  belongs_to :subfamily
  has_many :species, :class_name => 'Species', :order => :name
  has_many :subspecies, :class_name => 'Subspecies', :order => :name
  has_many :subgenera, :class_name => 'Subgenus', :order => :name

  scope :without_subfamily, where(:subfamily_id => nil)
  scope :without_tribe, where(:tribe_id => nil)

  def children
    species
  end

  def full_label
    "<i>#{full_name}</i>"
  end

  def full_name
    name
  end

  def statistics
    get_statistics [:species, :subspecies]
  end

  def siblings
    tribe && tribe.genera ||
    subfamily && subfamily.genera.without_tribe.all ||
    Genus.without_subfamily.all
  end

  def self.import data
    transaction do
      protonym = Protonym.import data[:protonym]
      attributes = {:name => data[:name], :status => 'valid', :protonym => protonym}
      attributes.reverse_merge! data[:attributes] if data[:attributes]
      genus = create! attributes
      data[:taxonomic_history].each do |item|
        genus.taxonomic_history_items.create! :text => item
      end
      target_name = data[:type_species][:genus_name] + ' ' + data[:type_species][:species_epithet]
      ForwardReference.create! :source_id => genus.id, :source_attribute => :type_taxon, :target_name => target_name
      genus
    end
  end

end
