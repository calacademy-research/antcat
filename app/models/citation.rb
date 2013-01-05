# coding: UTF-8
class Citation < ActiveRecord::Base
  belongs_to :reference

  def self.import data
    reference = Reference.find_by_bolton_key data
    notes_taxt = data[:notes] ? Importers::Bolton::Catalog::TextToTaxt.notes_item(data[:notes]) : nil
    create! reference: reference, pages: data[:pages], forms: data[:forms], notes_taxt: notes_taxt
  end

end
