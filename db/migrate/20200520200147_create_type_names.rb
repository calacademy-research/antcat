# frozen_string_literal: true

class CreateTypeNames < ActiveRecord::Migration[6.0]
  def change
    create_table :type_names, id: :integer do |t|
      t.integer :taxon_id, null: false
      t.integer :reference_id
      t.string :pages
      t.string :fixation_method

      t.timestamps null: false
    end

    add_index :type_names, :taxon_id
    add_foreign_key :type_names, :taxa, column: :taxon_id, name: "fk_type_names__taxon_id__taxa__id"

    add_index :type_names, :reference_id
    add_foreign_key :type_names, :references, name: "fk_type_names__reference_id__references__id"
  end
end
