class DropForwardRefs < ActiveRecord::Migration[4.2]
  def up
    drop_table :forward_refs
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
