# coding: UTF-8
module Importers::Bolton::Catalog::Updater

  def update_field field_name, new_value, attributes
    before = self[field_name]
    after = new_value
    if before != after
      Update.create! class_name: self.class.to_s, record_id: id, field_name: field_name,
        before: before, after: after
      attributes[field_name] = after
    end
  end

  def update_name_field field_name, new_name, attributes
    before = self.send field_name.to_sym
    after = new_name
    if before != after
      Update.create! class_name: self.class.to_s, record_id: id, field_name: field_name,
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
      Update.create! class_name: self.class.to_s, record_id: id, field_name: field_name,
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
        Update.create! class_name: 'TaxonHistoryItem', record_id: item.id, field_name: 'taxt',
          before: before, after: after
        item.update_attributes taxt: after
      end
      i += 1
    end
    # add new ones
    while i < history_data.count
      new_taxt = history_data[i]
      new_item = history_items.create! taxt: new_taxt
      Update.create! class_name: 'TaxonHistoryItem', record_id: new_item.id,
        field_name: 'taxt', before: nil, after: new_taxt
      i += 1
    end
    # delete deleted ones
    items_to_delete = []
    while i < history_items.count
      items_to_delete << history_items[i].id
      Update.create! class_name: 'TaxonHistoryItem', record_id: history_items[i].id,
        field_name: 'taxt', before: nil, after: nil
      i += 1
    end
    items_to_delete.each {|item| TaxonHistoryItem.delete item}
  end

  def update_family_or_subfamily_or_tribe data
    attributes = {}

    update_boolean_field  'fossil',              data[:fossil], attributes
    update_field          'status',              data[:status] || 'valid', attributes
    update_taxt_field     'headline_notes_taxt', data[:note], attributes

    type_attributes = self.class.get_type_attributes :type_genus, data
    update_name_field     'type_name',    type_attributes[:type_name], attributes
    update_field          'type_taxt',    type_attributes[:type_taxt], attributes
    update_boolean_field  'type_fossil',  type_attributes[:type_fossil], attributes

    update_attributes attributes

    protonym.update_data data[:protonym]
    update_history data[:history]
  end

  def update_synonyms
  end

end
