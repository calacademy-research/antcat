# coding: UTF-8
class GenusGroupTaxon < Taxon
  include Formatters::Formatter
  include Importers::Bolton::Catalog::Updater
  belongs_to :subfamily
  belongs_to :tribe

  def self.import data, attributes = {}
    taxon, name = find_taxon_to_update data
    transaction do
      if taxon
        taxon.update_status do
          taxon.update_data data
        end
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
        create_update name, taxon.id, self.name
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
    italicize name
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

  def parent= id_or_object
    parent_taxon = id_or_object.kind_of?(Taxon) ? id_or_object : Taxon.find(id_or_object)
    if parent_taxon.kind_of? Subfamily
      self.subfamily = parent_taxon
    elsif parent_taxon.kind_of? Tribe
      self.subfamily = parent_taxon.subfamily
      self.tribe = parent_taxon
    end
  end

  def parent
    send Rank[self].parent.read_selector
  end

end
