# coding: UTF-8
class GenusGroupTaxon < Taxon
  belongs_to :subfamily
  belongs_to :tribe

  def children
    species
  end

  def label
    "<i>#{name}</i>"
  end

  def inspect
    string = super
    string << ' (' if subfamily || tribe
    if subfamily
      string << " #{subfamily.name} #{subfamily.id}"
      string << " #{subfamily.status}" if subfamily.invalid?
    end
    if tribe
      string << " #{tribe.name} #{tribe.id}"
      string << " #{tribe.status}" if tribe.invalid?
    end
    string << ')' if subfamily || tribe
    string
  end

  def self.parent_attributes data, attributes
    {subfamily: data[:subfamily], tribe: data[:tribe]}
  end

  def self.import data, attributes = {}
    transaction do
      attributes.merge!(
        name:                 Name.import(data),
        fossil:               data[:fossil] || false,
        status:               data[:status] || 'valid',
        protonym:             Protonym.import(data[:protonym]),
        synonym_of:           data[:synonym_of],
        headline_notes_taxt:  Importers::Bolton::Catalog::TextToTaxt.convert(data[:note]),
      ).merge! parent_attributes data, attributes
      attributes.merge! data[:attributes] if data[:attributes]
      if data[:type_species]
        attributes[:type_name] = Name.import data[:type_species]
        attributes[:type_taxt] = Importers::Bolton::Catalog::TextToTaxt.convert data[:type_species][:texts]
      end
      taxon = create! attributes
      taxon.import_synonyms attributes
      taxon.import_taxonomic_history data
      taxon
    end
  end

  def import_taxonomic_history data
    for item in data[:taxonomic_history].select &:present?
      taxonomic_history_items.create! taxt: item
    end
  end

end
