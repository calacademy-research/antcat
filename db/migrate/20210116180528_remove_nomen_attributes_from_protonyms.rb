# frozen_string_literal: true

class RemoveNomenAttributesFromProtonyms < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      remove_column :protonyms, :nomen_novum, :boolean, default: false, null: false
      remove_column :protonyms, :nomen_oblitum, :boolean, default: false, null: false
      remove_column :protonyms, :nomen_dubium, :boolean, default: false, null: false
      remove_column :protonyms, :nomen_conservandum, :boolean, default: false, null: false
      remove_column :protonyms, :nomen_protectum, :boolean, default: false, null: false
    end
  end
end
