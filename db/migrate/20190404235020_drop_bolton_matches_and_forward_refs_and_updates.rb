class DropBoltonMatchesAndForwardRefsAndUpdates < ActiveRecord::Migration[5.2]
  def up
    drop_table :bolton_matches
    drop_table :forward_refs
    drop_table :updates
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
