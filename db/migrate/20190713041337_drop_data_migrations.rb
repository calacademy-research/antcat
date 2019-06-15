class DropDataMigrations < ActiveRecord::Migration[5.2]
  def up
    drop_table :data_migrations
  end

  def down
    fail ActiveRecord::IrreversibleMigration
  end
end
