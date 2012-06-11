# coding: UTF-8
class Subfamily < Taxon
  has_many :tribes
  has_many :genera
  has_many :species
  has_many :subspecies

  def self.import data
    transaction do
      attributes = {
        name_object:  Name.import(data),
        fossil:       data[:fossil] || false,
        status:       'valid',
        protonym:     Protonym.import(data[:protonym]),
      }
      if data[:type_genus]
        attributes[:type_name] = Name.import data[:type_genus]
        attributes[:type_taxon_taxt] = Importers::Bolton::Catalog::TextToTaxt.convert data[:type_genus][:texts]
      end
      subfamily = create! attributes
      data[:taxonomic_history].each do |item|
        subfamily.taxonomic_history_items.create! taxt: item
      end
      subfamily
    end
  end

  def children
    tribes
  end

  def statistics
    get_statistics [:genera, :species, :subspecies]
  end

end
