# coding: UTF-8
class Subfamily < Taxon
  has_many :tribes, :order => :name
  has_many :genera, :class_name => 'Genus', :order => :name
  has_many :species, :class_name => 'Species', :order => :name
  has_many :subspecies, :class_name => 'Subspecies', :order => :name

  def self.import data
    transaction do
      protonym = Protonym.import data[:protonym]

      attributes = {
        name: data[:name],
        fossil: data[:fossil] || false,
        status: 'valid',
        protonym: protonym,
      }
      if data[:type_genus]
        type_genus_taxt = Importers::Bolton::Catalog::TextToTaxt.convert(data[:type_genus][:texts])
        attributes[:type_taxon_taxt] = type_genus_taxt
      end
      subfamily = create! attributes
      data[:taxonomic_history].each do |item|
        subfamily.taxonomic_history_items.create! taxt: item
      end

      type_genus = data[:type_genus]
      ForwardReference.create! source_id: subfamily.id, 
        target_name: type_genus[:genus_name], fossil: type_genus[:fossil] if type_genus

      subfamily
    end
  end
  def children
    tribes
  end

  def full_name
    name
  end

  def full_label
    full_name
  end

  def statistics
    get_statistics [:genera, :species, :subspecies]
  end

end
