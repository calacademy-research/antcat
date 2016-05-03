class DropTaskReferences < ActiveRecord::Migration
  def up
    drop_table :task_references
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
