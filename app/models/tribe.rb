# coding: UTF-8
class Tribe < Taxon
  include Importers::Bolton::Catalog::Updater
  belongs_to :subfamily
  has_many :genera

  def self.import data
    taxon, name = find_taxon_to_update data
    transaction do
      if taxon
        taxon.update_status do
          taxon.update_data data
        end
      else
        attributes = {
          name:       name,
          fossil:     data[:fossil] || false,
          status:     data[:status] || 'valid',
          protonym:   Protonym.import(data[:protonym]),
          subfamily:  data[:subfamily],
        }
        attributes.merge! get_type_attributes data
        senior = data.delete :synonym_of
        taxon = create! attributes
        taxon.import_synonyms senior
        taxon.import_history data[:history]
        create_update name, taxon.id, self.name
      end
      taxon
    end
  end

  def self.get_type_key
    :type_genus
  end

  #########

  def children
    genera
  end

  def statistics
    get_statistics [:genera]
  end

  def siblings
    subfamily.tribes
  end

  def inspect
    string = super
    if subfamily
      string << ", #{subfamily.name} #{subfamily.id}"
      string << " #{subfamily.status}" if subfamily.invalid?
    end
    string
  end

end
