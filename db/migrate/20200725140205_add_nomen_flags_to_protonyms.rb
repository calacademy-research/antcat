# frozen_string_literal: true

class AddNomenFlagsToProtonyms < ActiveRecord::Migration[6.0]
  def change
    add_column :protonyms, :nomen_novum, :boolean, default: false, null: false
    add_column :protonyms, :nomen_oblitum, :boolean, default: false, null: false
    add_column :protonyms, :nomen_dubium, :boolean, default: false, null: false
    add_column :protonyms, :nomen_conservandum, :boolean, default: false, null: false
    add_column :protonyms, :nomen_protectum, :boolean, default: false, null: false
  end
end
