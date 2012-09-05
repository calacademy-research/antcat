# coding: UTF-8
class GenusGroupTaxon < Taxon
  belongs_to :subfamily
  belongs_to :tribe

  def children
    species
  end

  def label
    Formatters::Formatter.italicize name
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
    string << " #{id}"
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
        headline_notes_taxt:  Importers::Bolton::Catalog::TextToTaxt.convert(data[:note]),
      ).merge! parent_attributes data, attributes
      attributes.merge! data[:attributes] if data[:attributes]
      attributes.merge! get_type_attributes :type_species, data
      senior = attributes.delete :synonym_of
      taxon = create! attributes
      taxon.import_synonyms senior
      taxon.import_history data
      taxon
    end
  end

  def import_history data
    for item in data[:history].select &:present?
      history_items.create! taxt: item
    end
  end

end
