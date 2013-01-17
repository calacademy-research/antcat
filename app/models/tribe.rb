# coding: UTF-8
class Tribe < Taxon
  include Importers::Bolton::Catalog::Updater
  belongs_to :subfamily
  has_many :genera

  def self.import data
    name = Name.import data
    transaction do
      if tribe = find_by_name(name.name)
        tribe.update_data data
      else
        attributes = {
          name:       name,
          fossil:     data[:fossil] || false,
          status:     data[:status] || 'valid',
          protonym:   Protonym.import(data[:protonym]),
          subfamily:  data[:subfamily],
        }
        attributes.merge! get_type_attributes :type_genus, data
        senior = data.delete :synonym_of
        tribe = create! attributes
        tribe.import_synonyms senior
        tribe.import_history data[:history]
      end
      tribe
    end
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
