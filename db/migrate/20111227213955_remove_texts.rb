class RemoveTexts < ActiveRecord::Migration
  def up
    drop_table :texts
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
