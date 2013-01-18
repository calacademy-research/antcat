# coding: UTF-8
class GenusGroupTaxon < Taxon
  include Importers::Bolton::Catalog::Updater
  belongs_to :subfamily
  belongs_to :tribe

  def self.find_taxon_to_update data

  end
  def self.import data, attributes = {}
    taxon, name = get_taxon_to_update data
    transaction do
      if taxon
        taxon.update_data data
      else
        attributes.merge!(
          name:                 name,
          fossil:               data[:fossil] || false,
          status:               data[:status] || 'valid',
          protonym:             Protonym.import(data[:protonym]),
          headline_notes_taxt:  Importers::Bolton::Catalog::TextToTaxt.convert(data[:note]),
        ).merge! parent_attributes data, attributes
        attributes.merge! data[:attributes] if data[:attributes]
        attributes.merge! get_type_attributes data
        senior = attributes.delete :synonym_of
        taxon = create! attributes
        taxon.import_synonyms senior
        taxon.import_history data[:history]
      end
    end
    taxon
  end

  def self.parent_attributes data, attributes
    {subfamily: data[:subfamily], tribe: data[:tribe]}
  end

  def self.get_type_key
    :type_species
  end

  ###########
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

end
