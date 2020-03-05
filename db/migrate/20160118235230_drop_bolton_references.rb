class DropBoltonReferences < ActiveRecord::Migration[4.2]
  def up
    remove_column :references, :bolton_key_cache
    drop_table :bolton_matches
    drop_table :bolton_references
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
