# coding: UTF-8
module Importers::Bolton::Catalog::Updater

  module ClassMethods
    def get_taxon_to_update data
      name = Name.import data
      principal_author_last_name = data[:protonym][:authorship].first[:author_names]
      year = data[:protonym][:authorship].first[:year]
      taxon = find_by_name_and_authorship name.name, principal_author_last_name, year
      return taxon, name
    end
  end

  def self.included receiver
    receiver.extend ClassMethods
  end

  def update_field field_name, new_value, attributes
    before = normalize_field self[field_name]
    after = normalize_field new_value
    taxon_name = self.respond_to?(:name) ? name.name : nil
    if before != after
      Update.create! name: taxon_name, class_name: self.class.to_s, record_id: id, field_name: field_name,
        before: before, after: after
      attributes[field_name] = after
    end
  end

  def normalize_field value
    value.present? ? value : nil
  end

  def update_taxon_id_field field_name, new_value, attributes
    before_id = normalize_field self[field_name]
    after_id = normalize_field new_value
    if before_id != after_id
      before = before_id ? Taxon.find(before_id).name.name : nil
      after = after_id ? Taxon.find(after_id).name.name : nil
      update = Update.create! name: name.name, class_name: self.class.to_s, record_id: id, field_name: field_name,
        before: before, after: after
      attributes[field_name[0..-4]] = after_id ? Taxon.find(after_id) : nil
    end
  end

  def update_name_field field_name, new_name, attributes
    before = self.send field_name.to_sym
    after = new_name
    if before != after
      Update.create! name: name.name, class_name: self.class.to_s, record_id: id, field_name: field_name,
        before: before.try(:name), after: after.name
      attributes[field_name] = after
    end
  end

  def update_taxt_field field_name, new_value, attributes
    update_field field_name, Importers::Bolton::Catalog::TextToTaxt.convert(new_value), attributes
  end

  def update_boolean_field field_name, new_value, attributes
    before = normalize_boolean self[field_name]
    after = normalize_boolean new_value
    if before != after
      Update.create! name: name.name, class_name: self.class.to_s, record_id: id, field_name: field_name,
        before: before, after: after
      attributes[field_name] = after
    end
  end

  def normalize_boolean boolean
    case boolean
    when '1', true then true
    when '0', false, nil then false
    else raise
    end
  end

  def update_history history_data
    # compare and update common subset
    i = 0
    while i < history_items.count && i < history_data.count
      item = history_items.all[i]
      before = item.taxt
      after = history_data[i]
      if before != after
        Update.create! name: 'History', class_name: 'TaxonHistoryItem', record_id: item.id, field_name: 'taxt',
          before: before, after: after
        item.update_attributes taxt: after
      end
      i += 1
    end
    # add new ones
    while i < history_data.count
      new_taxt = history_data[i]
      new_item = history_items.create! taxt: new_taxt
      Update.create! name: 'History', class_name: 'TaxonHistoryItem', record_id: new_item.id,
        field_name: 'taxt', before: nil, after: new_taxt
      i += 1
    end
    # delete deleted ones
    items_to_delete = []
    while i < history_items.count
      items_to_delete << history_items[i].id
      Update.create! name: 'History', class_name: 'TaxonHistoryItem', record_id: history_items[i].id,
        field_name: 'taxt', before: nil, after: nil
      i += 1
    end
    items_to_delete.each {|item| TaxonHistoryItem.delete item}
  end

  def update_data data
    update_synonyms do
      senior = data.delete :synonym_of
      update_taxon data
      import_synonyms senior
    end
  end

  def update_taxon data
    attributes = {}
    update_taxon_fields data, attributes

    update_attributes attributes

    protonym.update_data data[:protonym]
    update_history data[:history]
  end

  def update_taxon_fields data, attributes
    if data[:attributes]
      data = data.dup
      data.merge! data[:attributes]
      data.delete :attributes
    end
    subfamily = data[:subfamily] ? data[:subfamily].id : nil
    tribe = data[:tribe] ? data[:tribe].id : nil
    type_attributes = self.class.get_type_attributes data

    update_taxon_id_field :subfamily_id, subfamily, attributes
    update_taxon_id_field :tribe_id, tribe, attributes

    update_boolean_field  'fossil',               data[:fossil], attributes
    update_field          'status',               data[:status] || 'valid', attributes

    headline_notes_taxt = data[:headline_notes_taxt] || data[:note] || data[:additional_notes]
    update_taxt_field     'headline_notes_taxt',  headline_notes_taxt, attributes

    update_field          :incertae_sedis_in,     data[:incertae_sedis_in], attributes
    update_boolean_field  'hong',                 data[:hong], attributes

    update_name_field     'type_name',            type_attributes[:type_name], attributes
    update_field          'type_taxt',            type_attributes[:type_taxt], attributes
    update_boolean_field  'type_fossil',          type_attributes[:type_fossil], attributes
  end

  def update_synonyms
    prior_junior_synonyms = junior_synonyms.to_a
    prior_senior_synonyms = senior_synonyms.to_a

    yield

    current_junior_synonyms = junior_synonyms(true).to_a
    current_senior_synonyms = senior_synonyms(true).to_a

    new_junior_synonyms = current_junior_synonyms - prior_junior_synonyms
    for junior_synonym in new_junior_synonyms
      Update.create! name: name.name, class_name: 'Tribe', record_id: id, field_name: 'senior_synonym_of',
        before: nil, after: junior_synonym.name.name
    end

    new_senior_synonyms = current_senior_synonyms.to_a - prior_senior_synonyms.to_a

    for senior_synonym in new_senior_synonyms
      Update.create! name: name.name, class_name: 'Tribe', record_id: id, field_name: 'junior_synonym_of',
        before: nil, after: senior_synonym.name.name
    end

    deleted_junior_synonyms = prior_junior_synonyms.to_a - current_junior_synonyms.to_a
    for junior_synonym in deleted_junior_synonyms
      Update.create! name: name.name, class_name: 'Tribe', record_id: id, field_name: 'senior_synonym_of',
        before: junior_synonym.name.name, after: nil
    end

    deleted_senior_synonyms = prior_senior_synonyms - current_senior_synonyms
    for senior_synonym in deleted_senior_synonyms
      Update.create! name: name.name, class_name: 'Tribe', record_id: id, field_name: 'junior_synonym_of',
        before: senior_synonym.name.name, after: nil
    end

  end
end
