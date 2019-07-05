class DropBoltonReferencesAgain < ActiveRecord::Migration[5.2]
  def up
    drop_table :bolton_references
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
