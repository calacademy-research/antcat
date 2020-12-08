# frozen_string_literal: true

class AddHybridHistoryItemsColumns < ActiveRecord::Migration[6.0]
  def up
    safety_assured do
      change_column :history_items, :taxt, :text, null: true

      add_column :history_items, :type, :string, null: false, default: 'Taxt'
      add_column :history_items, :subtype, :string
      add_column :history_items, :picked_value, :string
      add_column :history_items, :text_value, :string

      add_column :history_items, :reference_id, :integer
      add_column :history_items, :pages, :string
      add_column :history_items, :object_protonym_id, :integer

      add_foreign_key :history_items, :references,
        name: "fk_history_items__reference_id__references__id"
      add_foreign_key :history_items, :protonyms, column: 'object_protonym_id',
        name: "fk_history_items__object_protonym_id__protonyms__id"

      add_index :history_items, :type, name: 'ix_history_items__type'
      add_index :history_items, :subtype, name: 'ix_history_items__subtype'
      add_index :history_items, :reference_id, name: 'ix_history_items__reference_id'
      add_index :history_items, :object_protonym_id, name: 'ix_history_items__object_protonym_id'
    end
  end

  def down
    safety_assured do
      change_column :history_items, :taxt, :text, null: false

      remove_column :history_items, :type
      remove_column :history_items, :subtype
      remove_column :history_items, :picked_value
      remove_column :history_items, :text_value

      remove_column :history_items, :reference_id
      remove_column :history_items, :pages
      remove_column :history_items, :object_protonym_id
    end
  end
end
