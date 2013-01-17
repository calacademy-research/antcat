# coding: UTF-8
class GenusGroupTaxon < Taxon
  include Importers::Bolton::Catalog::Updater
  belongs_to :subfamily
  belongs_to :tribe

  def self.import data, attributes = {}
    name = Name.import data
    transaction do
      if taxon = find_by_name(name.name)
        taxon.update_data data
      else
        attributes.merge!(
          name:                 Name.import(data),
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
      taxon
    end
  end

  def self.parent_attributes data, attributes
    {subfamily: data[:subfamily], tribe: data[:tribe]}
  end

  def update_data data
    update_synonyms do
      senior = data.delete :synonym_of
      update_taxon data
      import_synonyms senior
    end
  end

  def update_taxon_fields data, attributes
    super
    update_taxon_field :subfamily_id, data[:subfamily].id, attributes
    update_taxon_field :tribe_id, data[:tribe].id, attributes
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
