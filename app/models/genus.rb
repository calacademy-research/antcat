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

  def self.import data, attributes = {}
    transaction do
      attributes.merge!(
        name_object:          Name.import(data),
        fossil:               data[:fossil] || false,
        status:               data[:status] || 'valid',
        protonym:             Protonym.import(data[:protonym]),
        subfamily:            data[:subfamily],
        tribe:                data[:tribe],
        synonym_of:           data[:synonym_of],
        headline_notes_taxt:  Importers::Bolton::Catalog::TextToTaxt.convert(data[:note])
      )
      attributes.merge! data[:attributes] if data[:attributes]
      if data[:type_species]
        attributes[:type_name] = Name.import data[:type_species]
        attributes[:type_taxon_taxt] = Importers::Bolton::Catalog::TextToTaxt.convert data[:type_species][:texts]
      end
      genus = create! attributes
      data[:taxonomic_history].each do |item|
        genus.taxonomic_history_items.create! taxt: item if item.present?
      end
      genus
    end
  end

end
