# coding: UTF-8
class Tribe < Taxon
  include Importers::Bolton::Catalog::Updater
  belongs_to :subfamily
  has_many :genera

  def self.import data
    taxon, name = get_taxon_to_update data
    transaction do
      if taxon
        taxon.update_data data
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
        tribe = create! attributes
        tribe.import_synonyms senior
        tribe.import_history data[:history]
      end
      tribe
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
