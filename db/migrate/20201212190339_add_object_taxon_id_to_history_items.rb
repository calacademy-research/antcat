# frozen_string_literal: true

class AddObjectTaxonIdToHistoryItems < ActiveRecord::Migration[6.0]
  def up
    add_column :history_items, :object_taxon_id, :integer

    add_index :history_items, :object_taxon_id, name: 'ix_history_items__object_taxon_id'
    add_foreign_key :history_items, :taxa, column: 'object_taxon_id',
      name: "fk_history_items__object_taxon_id__taxa__id"

    # Commented out failed and now fixed rename.
    # add_index :history_items, :object_protonym_id, name: 'ix_history_items__object_taxon_id'
  end

  def down
    remove_column :history_items, :object_taxon_id
  end
end
