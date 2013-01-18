# coding: UTF-8
class Subfamily < Taxon
  include Importers::Bolton::Catalog::Updater
  has_many :tribes
  has_many :genera
  has_many :species
  has_many :subspecies
  has_many :collective_group_names, class_name: 'Genus', conditions: 'status = "collective group name"'

  def self.import data
    name = Name.import data
    transaction do
      if subfamily = find_by_name(name.name)
        subfamily.update_data data
      else
        attributes = {
          name:                name,
          fossil:              data[:fossil] || false,
          status:              data[:status] ||'valid',
          protonym:            Protonym.import(data[:protonym]),
          headline_notes_taxt: data[:headline_notes_taxt],
        }
        attributes.merge! get_type_attributes data
        subfamily = create! attributes
        subfamily.import_history data[:history]
      end
      subfamily
    end
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
