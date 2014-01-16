class RenameNestedReferenceId < ActiveRecord::Migration
  def up
    rename_column :references, :nested_reference_id, :nester_id
  end

  def down
    rename_column :references, :nester_id, :nested_reference_id
  end
end
