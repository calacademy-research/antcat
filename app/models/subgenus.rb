# coding: UTF-8
class Subgenus < GenusGroupTaxon
  belongs_to :genus
  validates_presence_of :genus
  belongs_to :tribe
  has_many :species

  def self.import data, attributes = {}
    transaction do
      attributes.merge!(
        name_object:          Name.import(data),
        fossil:               data[:fossil] || false,
        status:               data[:status] || 'valid',
        protonym:             Protonym.import(data[:protonym]),
        genus:                data[:genus],
        synonym_of:           data[:synonym_of],
        headline_notes_taxt:  Importers::Bolton::Catalog::TextToTaxt.convert(data[:note])
      )
      attributes.merge! data[:attributes] if data[:attributes]
      if data[:type_species]
        attributes[:type_name] = Name.import data[:type_species]
        attributes[:type_taxt] = Importers::Bolton::Catalog::TextToTaxt.convert data[:type_species][:texts]
      end
      subgenus = create! attributes
      data[:taxonomic_history].each do |item|
        subgenus.taxonomic_history_items.create! taxt: item if item.present?
      end
      subgenus
    end
  end

  def statistics
  end

end
