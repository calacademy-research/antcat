class RenameNester < ActiveRecord::Migration[4.2]
  def up
    rename_column :references, :nester_id, :nesting_reference_id
    remove_column :references, :key_cache_no_commas
  end

  def down
    add_column :references, :key_cache_no_commas, :text
    rename_column :references, :nesting_reference_id, :nester_id
  end
end
