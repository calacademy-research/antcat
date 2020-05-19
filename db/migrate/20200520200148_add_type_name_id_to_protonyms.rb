# frozen_string_literal: true

class AddTypeNameIdToProtonyms < ActiveRecord::Migration[6.0]
  def change
    add_column :protonyms, :type_name_id, :integer
    add_foreign_key :protonyms, :type_names, name: "fk_protonyms__type_name_id__type_names__id"
    add_index :protonyms, :type_name_id, unique: true
  end
end
