# coding: UTF-8
class Tribe < Taxon
  belongs_to :subfamily
  has_many :genera

  def children
    genera
  end

  def statistics
  end

  def siblings
    subfamily.tribes
  end

  def self.import data
    transaction do
      attributes = {
        name_object:  Name.import(data),
        fossil:       data[:fossil] || false,
        status:       data[:status] || 'valid',
        protonym:     Protonym.import(data[:protonym]),
        subfamily:    data[:subfamily],
        synonym_of:   data[:synonym_of],
      }
      if data[:type_genus]
        attributes[:type_name] = Name.import data[:type_genus]
        attributes[:type_taxon_taxt] = Importers::Bolton::Catalog::TextToTaxt.convert data[:type_genus][:texts]
      end
      tribe = create! attributes
      data[:taxonomic_history].each do |item|
        tribe.taxonomic_history_items.create! taxt: item
      end
      tribe
    end
  end

end
