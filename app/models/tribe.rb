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
      previous_junior_synonyms = junior_synonyms
      previous_senior_synonyms = senior_synonyms

      update_taxon data

      current_junior_synonyms = junior_synonyms
      current_senior_synonyms = senior_synonyms

      new_junior_synonyms = current_junior_synonyms - previous_junior_synonyms
      for junior_synonym in new_junior_synonyms
        Update.create! class_name: 'Tribe', record_id: id, field_name: 'senior_synonym_of',
          before: nil, after: junior_synonym.name.name
      end

      deleted_junior_synonyms = previous_junior_synonyms - current_junior_synonyms
      for junior_synonym in deleted_junior_synonyms
        Update.create! class_name: 'Tribe', record_id: id, field_name: 'senior_synonym_of',
          before: junior_synonym.name.name, after: nil
        Synonym.where([junior_synonym_id: junior_synonym, senior_synonym_id: id]).destroy_all
      end

      #new_senior_synonyms = current_senior_synonyms - previous_senior_synonyms
      #for senior_synonym in new_senior_synonyms
        #Update.create! class_name: 'Tribe', record_id: id, field_name: 'senior_synonym_of',
          #before: nil, after: senior_synonym.senior_synonym
      #end
    end

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
