# coding: UTF-8
module Updater

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

end
