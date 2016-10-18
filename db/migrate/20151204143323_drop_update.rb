class DropUpdate < ActiveRecord::Migration
  def up
    drop_table :updates
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
