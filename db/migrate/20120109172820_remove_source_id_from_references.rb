class RemoveSourceIdFromReferences < ActiveRecord::Migration
  def up
    remove_column :references, :source_reference_id
    remove_column :references, :source_reference_type
  end

  def down
    add_column :references, :source_reference_type
    add_column :references, :source_reference_id
  end
end
