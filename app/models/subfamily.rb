# coding: UTF-8
class Subfamily < Taxon
  include Importers::Bolton::Catalog::Updater
  belongs_to :family
  has_many :tribes
  has_many :genera
  has_many :species
  has_many :subspecies
  has_many :collective_group_names, class_name: 'Genus', conditions: 'status = "collective group name"'

  def self.import data
    taxon, name = find_taxon_to_update data
    transaction do
      if taxon
        taxon.update_status do
          taxon.update_data data
        end
      else
        attributes = {
          name:                name,
          fossil:              data[:fossil] || false,
          status:              data[:status] ||'valid',
          protonym:            Protonym.import(data[:protonym]),
          headline_notes_taxt: Importers::Bolton::Catalog::TextToTaxt.convert(data[:headline_notes_taxt]),
        }
        attributes.merge! get_type_attributes data
        taxon = create! attributes
        taxon.import_history data[:history]
        create_update name, taxon.id, self.name
      end
    end
    taxon
  end

  def add_antweb_attributes attributes
    attributes.merge subfamily: name.to_s
  end

  def self.get_type_key
    :type_genus
  end

  #########

  def children
    tribes
  end

  def statistics
    get_statistics [:tribes, :genera, :species, :subspecies]
  end

end
