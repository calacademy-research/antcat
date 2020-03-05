class DropTaskReferences < ActiveRecord::Migration[4.2]
  def up
    drop_table :task_references
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
