# coding: UTF-8
class Tribe < Taxon
  belongs_to :subfamily
  has_many :genera

  def children
    genera
  end

  def full_name
    name
  end

  def full_label
    full_name
  end

  def statistics
  end

  def siblings
    subfamily.tribes
  end

  def self.import data
    transaction do
      protonym = Protonym.import data[:protonym]
      name = Name.import data[:name]

      attributes = {
        name:       name,
        fossil:     data[:fossil] || false,
        subfamily:  data[:subfamily],
        synonym_of: data[:synonym_of],
        status:     data[:status] || 'valid',
        protonym:   protonym,
      }
      if data[:type_genus]
        type_genus_taxt = Importers::Bolton::Catalog::TextToTaxt.convert(data[:type_genus][:texts])
        attributes[:type_taxon_taxt] = type_genus_taxt
      end

      tribe = create! attributes

      data[:taxonomic_history].each do |item|
        tribe.taxonomic_history_items.create! taxt: item
      end

      type_genus = data[:type_genus]
      ForwardReference.create! source_id: tribe.id, 
        target_name: type_genus[:genus_name], fossil: type_genus[:fossil] if type_genus

      tribe
    end
  end
end
