# coding: UTF-8
class Citation < ActiveRecord::Base
  include Updater
  belongs_to :reference

  def self.import data
    reference = Reference.find_by_bolton_key data
    notes_taxt = data[:notes] ? Importers::Bolton::Catalog::TextToTaxt.notes_item(data[:notes]) : nil
    create! reference: reference, pages: data[:pages], forms: data[:forms], notes_taxt: notes_taxt
  end

  def update_data data
    attributes = {}
    update_reference data
    update_field 'pages', data[:pages], attributes
    update_field 'forms', data[:forms], attributes
    update_notes_taxt data, attributes
    update_attributes attributes
  end

  def update_reference data
    before = reference
    after = Reference.find_by_bolton_key data
    if before != after
      Update.create! class_name: self.class.to_s, record_id: id, field_name: 'reference',
        before: before.key.to_s, after: after.key.to_s
      self.reference = after
    end
  end

end
