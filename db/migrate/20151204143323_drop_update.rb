class DropUpdate < ActiveRecord::Migration[4.2]
  def up
    drop_table :updates
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
