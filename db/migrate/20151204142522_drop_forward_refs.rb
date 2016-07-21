class DropForwardRefs < ActiveRecord::Migration
  def up
    drop_table :forward_refs
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
