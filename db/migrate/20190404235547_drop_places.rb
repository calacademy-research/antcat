class DropPlaces < ActiveRecord::Migration[5.2]
  def up
    remove_column :publishers, :place_id
    drop_table :places
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
